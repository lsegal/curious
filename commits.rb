class Life
  def self.load(input)
    rows = input.split("\n")
    board = Life.new(rows[0].size - 2, rows.size - 2)
    rows[1...-1].each_with_index do |row, y|
      row.strip.split(//)[1...-1].each_with_index do |col, x|
        board[x, y] = (col == 'o' ? 1 : 0)
      end
    end
    board
  end

  def initialize(width, height)
    @neighbors, @pos = {}, {}
    @width, @height = width, height
    @board = [0] * (@width * @height)
  end

  def to_s
    rows = []
    rows << ('-' * (@width + 2))
    @height.times do |y|
      row = '|'
      @width.times do |x|
        row << (self[x, y] == 1 ? 'o' : ' ')
      end
      row << '|'
      rows << row
    end
    rows << ('-' * (@width + 2))
    rows.join("\n")
  end

  def play
    new_board = [0] * (@width * @height)
    @height.times do |y|
      @width.times do |x|
        new_board[pos(x, y)] =
          case count_neighbors(x, y)
          when 0, 1; 0
          when 2;    self[x, y] > 0 ? 1 : 0
          when 3;    1
          else       0
          end
      end
    end
    @board = new_board
    @neighbors = {}
    self
  end

  def count_neighbors(x, y)
    return @neighbors[[x,y]] if @neighbors[[x,y]]
    neighbors = 0
    (y-1).upto(y+1) do |row|
      (x-1).upto(x+1) do |col|
        next if row == y && col == x
        neighbors += self[col, row]
      end
    end
    @neighbors[[x,y]] = neighbors
  end

  def [](x, y)
    @board[pos(x, y)]
  rescue ArgumentError
    0
  end

  def []=(x, y, v)
    @board[pos(x, y)] = v
  rescue ArgumentError
    nil
  end

  def pos(x, y)
    return @pos[[x,y]] if @pos[[x,y]]
    v = y * @width + x
    raise ArgumentError if v < 0 || v >= @board.size
    @pos[[x,y]] = v
  end
end

commits = 1
time = Time.new(2012, 9, 13).utc.to_i
end_time = Time.now.utc.to_i

while time < end_time
  board = Life.load(File.readlines('README.md')[-21, 20].join)
  File.open('README.md', 'w') do |file|
    file.puts <<-eof
# Curious

A repository to explore how GitHub contribution graphs work

```
#{board.play}
```
eof
  end
  cmd = "git commit -a -m 'Commit #{commits}' --date '#{Time.at(time)}' && " +
        "git tag v#{commits}"
  puts cmd
  `#{cmd}`
  time += 21700
  commits += 1
end
