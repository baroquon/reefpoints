defmodule Reefpoints do
  def build do
    data =
      File.ls!("source/posts")
      |> Enum.reduce(%{"posts" => [], "tags" => []}, fn(path, %{"posts" => posts, "tags" => tags}) ->
        [_, yaml, body] = File.read!("source/posts/#{path}") |> String.split("---", parts: 3)
        yaml = YamlElixir.read_from_string(yaml)
        [_, year, month, day, slug_title] = Regex.run(~r/(\d{4})-(\d{2})-(\d{2})-([\w|-]+)\.md/, path)

        post_tags = normalize_tags(yaml["tags"])
        date = "#{year}-#{month}-#{day}T00:00:00"
        post = %{
          "id" => slugify_post([year, month, day], slug_title),
          "title" => yaml["title"],
          "employee" => parameterize(yaml["author"]),
          "summary" => yaml["summary"],
          "legacy" => false,
          "date" => date,
          "tags" => post_tags,
          "body" => body
        }

        post =
          body
          |> Earmark.as_html!()
          |> Floki.find("img")
          |> case do
            [] -> post
            tag ->
              src = Floki.attribute(tag, "src") |> List.first()
              alt = Floki.attribute(tag, "alt") |> List.first()
              Map.merge(post, %{"illustration" => src, "illustration_alt" => alt})
          end

        posts = List.insert_at(posts, -1, post)
        tags = Enum.concat(tags, post_tags)

        %{"posts" => posts, "tags" => tags}
      end)

    tags =
      data["tags"]
      |> Enum.uniq()
      |> Enum.map(fn(tag) -> 
        %{
          "id" => parameterize(tag),
          "name" => tag_name(tag)
        }
      end)
    json = Poison.encode!(%{"posts" => data["posts"], "tags" => tags})

    File.write("posts.json", json)
  end

  defp tag_name(tag) do
    String.downcase(tag)
    |> case do
      "rails" -> "Ruby on Rails"
      "jquery" -> "jQuery"
      "postgres" -> "PostgreSQL"
      "javascript" -> "JavaScript"
      "ember" -> "Ember.js"
      "backbone" -> "Backbone.js"
      "diy" -> "DIY"
      "es6" -> "ES6"
      "progressive-web-apps" -> "Progressive Web Apps"
      tag ->
        tag
        |> String.split(" ")
        |> Enum.map(&(String.downcase(&1) |> String.capitalize()))
        |> Enum.join(" ")
    end
  end

  defp normalize_tags(nil), do: []
  defp normalize_tags(tags) when is_binary(tags) do
    tags
    |> String.split(~r/,\s+/)
    |> normalize_tags()
  end
  defp normalize_tags(tags) when is_list(tags) do
    Enum.map(tags, &normalize_tag/1)
  end

  defp normalize_tag(tag) do
    String.downcase(tag)
    |> case do
      tag when tag in ~w(ember.js ember emberjs) -> "ember"
      tag when tag in ["ember-cli", "ember cli"] -> "ember-cli"
      tag when tag in ~w(jobs job) -> "job"
      tag when tag in ~w(observations observation) -> "observations"
      tag when tag in ["rails", "ruby on rails"] -> "rails"
      tag when tag in ~w(postgres postgresql) -> "postgres"
      tag when tag in ~w(javascript js) -> "javascript"
      tag when tag in ~w(backbone.js backbone) -> "backbone"
      tag when tag in ~w(pwa progressive-web-app progressive-web-apps) -> "progressive-web-apps"
      tag -> tag
    end
    |> parameterize()
  end

  defp slugify_post(date, slug_title) do
    date
    |> List.insert_at(-1, slug_title)
    |> Enum.join("/")
  end

  defp parameterize(name) do
    name 
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
  end
end
