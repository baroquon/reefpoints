---
layout: post
title: "Building An Image Upload API With Phoenix"
social: true
author: Alex Garibay
twitter: "_alexgaribay"
github: alexgaribay
summary: "Learn how to create an image upload API with Elixir and Phoenix."
published: true
tags: engineering, elixir, phoenix
---

![File Upload with Phoenix Logo in the background](https://i.imgur.com/xKrSHaM.png)

For many API applications, there comes a time when the application needs to save images uploaded to the server either locally or on a CDN. Luckily for us, Elixir and Phoenix provide the tools we need to build a simple image upload API.

## The Simple API

Let's define exactly how this API is supposed to work:

* accept a request containing a base64 encoded image as a field
* preserve the image extension by reading the image binary
* upload the image to Amazon's S3
* provide the URL to the image on S3 in the response

## Update Your Dependencies

To assist us with uploading images to S3, we will use [ExAws](https://github.com/CargoSense/ex_aws) to interact with the AWS API, [sweet_xml](https://github.com/kbrw/sweet_xml) for XML parsing, and [UUID]() to help generate random IDs. Update your `mix.exs` file to include both libraries as dependencies.

```elixir
def deps do
  [
    ...,
    {:ex_aws, "~> 1.1"},
    {:sweet_xml, "~> 0.6.5"},
    {:uuid, "~> 1.1"}
  ]
end
```

Also, make sure to update your application list if you're using Elixir 1.3 or lower.

```elixir
def application do
  [
    applications: [
      ...,
      :ex_aws,
      :hackney,
      :poison,
      :sweet_xml,
      :UUID
    ]
  ]
end
```

Lastly, include your AWS credentials in your `config.exs`.

```elixir
config :ex_aws,
  access_key_id: ["ACCESS_KEY_ID", :instance_role],
  secret_access_key: ["SECRET_ACCESS_KEY", :instance_role]
```

## The AssetStore "Context"

Before we create the controller, let's define the application logic in a separate module that is specific for handling uploaded assets. For our application, we are only going to support JPEG and PNG files. With a name like `AssetStore`, we can add additional file types in the future but use the same context.

```elixir
defmodule MyApp.AssetStore do
  @moduledoc """
  Responsible for accepting files and uploading them to an asset store.
  """
  
  import SweetXml
  alias ExAws.S3
  
  @doc """
  Accepts a base64 encoded image and uploads it to S3.

  ## Examples
  
      iex> upload_image(...)
      "https://image_bucket.s3.amazonaws.com/dbaaee81609747ba82bea2453cc33b83.png"
      
  """
  @spec upload_image(String.t) :: s3_url :: String.t
  def upload_image(image_base64) do
    # Decode the image
    {:ok, image_binary} = Base.decode64(image_base64)

    # Generate a unique filename
    filename =
      image_binary
      |> image_extension()
      |> unique_filename()
		  
    # Upload to S3
    {:ok, response} = 
      S3.put_object("image_bucket", filename, image_binary)
      |> ExAws.request()
    
    # Return the URL to the file on S3
    response.body
    |> SweetXml.xpath(~x"//Location/text()")
    |> to_string()
  end
  
  # Generates a unique filename with a given extension
  defp unique_filename(extension) do
    UUID.uuid4(:hex) <> extension
  end
  
  # Helper functions to read the binary to determine the image extension
  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xff, 0xD8, _::binary>>), do: ".jpg"
end
```

## Designing the Controller

Create a new controller responsible for images. We simply need to call our module that we previously made.

```elixir
defmodule MyApp.ImageController do
  use MyApp.Web, :controller
  
  def create(conn, %{"image" => image_base64}) do
    s3_url = MyApp.AssetStore.upload(image_base64)
    
    conn
    |> put_status(201)
    |> json(%{"url" => s3_url})
  end
end
```

Now let's go update our router to include the new route in our API.

```elixir
scope "/api", MyApp do
  ...
  
  # Our new images route
  resources "/images", ImageController, only: [:create]
end
```

Our application is now ready to accept images!

## Try It Out

We can easily try out our new API by hitting up our terminal for a quick run-through with cURL. We can try uploading a 1x1 transparent PNG file.

```
curl -X "POST" "http://localhost:4000/api/images" \
     -H "Content-Type: application/json" \
     -d $'{
  "image": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
}'

{"url": "https://image_bucket.s3.amazonaws.com/dbaaee81609747ba82bea2453cc33b83.png"}
```


## Wrap Up

As we can see, Elixir and Phoenix provide the tools to add an API to accept base64 encoded image uploads with very little code. Be sure to read the docs of the dependencies we leveraged.
