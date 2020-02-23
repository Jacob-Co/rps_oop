class Move
  attr_reader :value
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def reset_score
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must set a name"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry invalid choice"
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def loading
    3.times do
      print '.'
      sleep 0.55
    end
    puts
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    loading

    puts "#{computer.name} chose #{computer.move}"
  end

  def display_round_winner
    if human.move > computer.move
      puts "#{human.name} gains one point!"
    elsif computer.move > human.move
      puts "#{computer.name} gains one point!"
    else
      puts "It's a tie"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n"
    end

    return true if answer.downcase == 'y'
    return false if answer.downcase == 'n'
  end

  def display_score
    puts "#{human.name} : #{human.score}"
    puts "#{computer.name} : #{computer.score}"
  end

  def win_condition?
    !!(match_winner)
  end

  def match_winner
    return human if human.score >= 3
    return computer if computer.score >= 3
  end

  def display_winner
    puts "#{match_winner.name} wins the match" if win_condition?
  end

  def award_point
    if human.move > computer.move
      human.score += 1
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def play
    display_welcome_message

    loop do
      match
      display_winner
      human.reset_score
      computer.reset_score
      break unless play_again?
    end
    display_goodbye_message
  end

  def match
    loop do
      human.choose
      computer.choose
      display_moves
      loading
      display_round_winner
      award_point
      display_score
      break if win_condition?
      loading
    end
  end
end

RPSGame.new.play
