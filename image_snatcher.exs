matcher = ~r/\.(jpg|jpeg|png|bmp)$/
matched_files = File.ls!(Enum.filter(&(Regex.match?(matcher, &1))))
# Same as matched_files = File.ls!(Enum.filter(fn x -> (Regex.match?(matcher, x))))

num_matched = Enum.count(matched_files)
msg_end = case num_matched do
   1 -> "file"
   _ -> "files"
end
IO.puts("Matched #{num_matched} #{msg_end}")

case File.mkdir("./images") do
  :ok       -> IO.puts("./images directory Successfully created!")
  {:error, _} -> IO.puts("Could not create ./images directory")
end

Enum.each(matched-files, fn filename ->
  case File.rename(filename, "./images/#{filename}") do
    :ok       -> IO.puts("#{filename} successfully moved to images directory")
    {:error, -} -> IO.puts("Error moving #{filename} to images directory")
  end
end)
