defmodule BMP do

  def file_header(offset \\ 26) do
    file_type = "BM"
    file_size = <<0::little-size(32)>> # zero for uncompressed
    reserved = <<0::little-size(32)>> # always zero
    bitmap_offset = <<offset::little-size(32)>> #number of bytes
    file_type <> file_size <> reserved <> bitmap_offset
  end

  def example_data(width, height) do
    for row <- 1..height, into: <<>> do
      for item <- 1..width, into: <<>>  do
        pixel(80 + 5 * item, 6 * row, 6 * item + row)
      end
      <> padding_for(width, 24)
    end
  end

  def example_file(width \\ 32, height \\ 32, name \\ "example.bmp") do
    save_file(name, file_header() <> win2x_header(width, height), example_data(width, height))
  end

  def example_monochrome(width \\ 500, height \\ 500, name \\ "monochrome.bmp") do
    header = file_header(26 + 3 * 2) <> win2x_header(width, height, 1)
    palette = win2x_palette([[255, 0, 128], [127, 255, 128]])
    data = for row <- 1..height, into: <<>> do
      cols = for col <- 1..width, into: <<>>  do
        <<(if row * row + col * col > 100_000, do: 1, else: 0)::size(1)>>
      end
      <<cols::bitstring, padding_for(width, 4)::bitstring>>
    end
    File.write!(name, header <> palette <> data)
  end

  def example_4bit(width \\ 400, height \\ 400, name \\ "4bit.bmp") do
    header = file_header(26 + 3 * 16) <> win2x_header(width, height, 4)
    colors = [[0, 0, 0], [15, 15, 15], [31, 31, 31], [47, 47, 47],
              [63, 63, 63], [79, 79, 79], [95, 95, 95], [111, 111, 111],
              [127, 127, 127], [143, 143, 143], [159, 159, 159], [175, 175, 175],
              [191, 191, 191], [207, 207, 207], [223, 223, 223], [239, 239, 239]]
    palette = win2x_palette(colors)
    data = for row <- 1..height, into: <<>> do
      cols = for col <- 1..width, into: <<>>  do
        <<rem(div(col-1,25), 16)::size(4)>>
      end
      <<cols::bitstring, padding_for(width, 4)::bitstring>>
    end
    File.write!(name, header <> palette <> data)
  end

  def pixel(blue, green, red) do
    <<blue::little-size(8), green::little-size(8), red::little-size(8)>>
  end

  def padding_for(width, bpp \\ 24) do
    bits_past = rem(width * bpp, 32)
    num = if bits_past > 0, do: (32 - bits_past), else: 0
    <<0::size(num)>>
  end

  def save_file(filename, header, data) do
    File.write!(filename, header <> data)
  end

  def win2x_header(width, height, bits_per_pixel \\ 24) do
    size = <<12::little-size(32)>>
    w = <<width::little-size(16)>>
    h = <<height::little-size(16)>>
    planes = <<1::little-size(16)>>
    bpp = <<bits_per_pixel::little-size(16)>>
    size <> w <> h <> planes <> bpp
  end

  def win2x_palette(colors) do
    Enum.into(colors, <<>>, &(apply(BMP, :pixel, &1)))
  end
end
