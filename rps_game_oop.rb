class Move
  attr_reader :value
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  VALUES_SHORT = { 'r' => 'rock', 'p' => 'paper', 'l' => 'lizard',
                   'sc' => 'scissors', 'sp' => 'spock' }

  def to_s
    @value
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end

  def >(other_move)
    other_move.value == 'scissors' || other_move.value == 'lizard'
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end

  def >(other_move)
    other_move.value == 'paper' || other_move.value == 'lizard'
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end

  def >(other_move)
    other_move.value == 'rock' || other_move.value == 'spock'
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
  end

  def >(other_move)
    other_move.value == 'spock' || other_move.value == 'paper'
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
  end

  def >(other_move)
    other_move.value == 'rock' || other_move.value == 'scissors'
  end
end

class Player
  attr_accessor :move, :name, :score
  INIT_CHOICE = { 'rock' => Rock.new, 'paper' => Paper.new,
                  'scissors' => Scissors.new, 'spock' => Spock.new,
                  'lizard' => Lizard.new }

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

  def move_shortcuts
    Move::VALUES_SHORT.map do |short, long|
      if short != Move::VALUES_SHORT.keys.last
        "'#{short}' = #{long}, "
      else
        "'#{short}' = #{long}"
      end
    end
  end

  def choose
    choice = nil
    loop do
      puts "Please choose #{Move::VALUES.join(', ')}:"
      puts "Shortcuts: " + move_shortcuts.join
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      choice = Move::VALUES_SHORT[choice]
      break if Move::VALUES.include?(choice)
      puts "Sorry invalid choice"
    end
    self.move = INIT_CHOICE[choice]
  end
end

class Computer < Player
  def choose
    self.move = INIT_CHOICE[ai_choose]
  end

  def ==(other_computer)
    name == other_computer.name
  end
end

class R2d2 < Computer
  def set_name
    self.name = "R2D2"
  end

  def ai_choose
    Move::VALUES.sample
  end
end

class Hal < Computer
  def set_name
    self.name = "Hal"
  end

  def ai_choose
    ['spock', 'spock', 'scissors', 'lizard', 'spock', 'lizard'].sample
  end
end

class Chappie < Computer
  def set_name
    self.name = "Chappie"
  end

  def ai_choose
    ['rock', 'paper', 'scissors'].sample
  end
end

class Sonny < Computer
  def set_name
    self.name = "Sonny"
  end

  def ai_choose
    ['rock', 'rock', 'scissors', 'lizard'].sample
  end
end

class Number5 < Computer
  def initialize
    super
    @counter = 0
    @choices = ['paper', 'spock', Move::VALUES.sample,
                'lizard', 'lizard', 'spock']
  end

  def set_name
    self.name = "Number5"
  end

  def ai_choose
    ret = @choices[@counter]
    @counter += 1
    @counter = 0 if @counter >= @choices.size
    ret
  end
end

class GameHistory
  attr_reader :human, :computer

  def initialize(human, computer)
    @move_number = 1
    @round_number = 1
    @round_history = {}
    @match_history = { 0 => "Start of round #{@round_number}" }
    @human = human
    @computer = computer
    @human_rounds_won = 0
    @computer_rounds_won = 0
  end

  def change_computer(computer)
    @computer = computer
  end

  def record_move
    @match_history[@move_number] = "Turn #{@move_number} \n" \
                                   "#{human.name} chose #{human.move} \n" \
                                   "#{computer.name} chose #{computer.move}\n"
    @move_number += 1
  end

  def record_round_winner(winner)
    if winner == human
      @match_history['winner'] = "#{human.name} won round " \
                                 "#{@round_number} \n"
      @human_rounds_won += 1
    elsif winner == computer
      @match_history['winner'] = "#{computer.name} won round " \
                                 "#{@round_number} \n"
      @computer_rounds_won += 1
    end
  end

  def record_match
    @round_history[@round_number] = @match_history
    @round_number += 1
    @match_history = { 0 => "Start of round #{@round_number}" }
    @move_number = 1
  end

  def display_move_history?
    puts "Would you like to view the move history? (y/n)"
    loop do
      answer = gets.chomp
      return true if answer.downcase == 'y'
      return false if answer.downcase == 'n'
      puts "Please type 'y' or 'n'"
    end
  end

  def view_another_round?
    puts "Do you want to view another round? (y/n)"
    loop do
      answer = gets.chomp
      return true if answer.downcase == 'y'
      return false if answer.downcase == 'n'
      puts "Please input 'y' or 'n'"
    end
  end

  def display_moves(n)
    n = n.to_i
    @round_history[n].values.each do |report|
      puts report
      puts
    end
  end

  def choose_round
    choices = (1..(@round_number - 1)).to_a.map(&:to_s)
    puts "Choose what round number to view. From " \
         "1 to #{@round_number - 1}"
    loop do
      answer = gets.chomp
      return answer if choices.include?(answer)
      puts "Please choose a number from 1 to #{@round_number - 1}"
    end
  end

  def move_history_interface
    return nil unless display_move_history?
    if (@round_number - 1) == 1
      display_moves(1)
    else
      loop do
        answer = choose_round
        display_moves(answer)
        break unless view_another_round?
      end
    end
  end
end

class RPSGame
  attr_accessor :human, :computer, :history

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = [R2d2.new, Hal.new, Chappie.new, Sonny.new, Number5.new].sample
    @history = GameHistory.new(@human, @computer)
  end

  def display_welcome_message
    puts "Welcome to #{Move::VALUES.map(&:capitalize).join(', ')}!"
  end

  def display_goodbye_message
    puts "Thanks for playing #{Move::VALUES.map(&:capitalize).join(', ')}."
    puts 'Good bye!'
  end

  def loading
    3.times do
      print '.'
      sleep 0.35
    end
    puts
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    loading

    puts "#{computer.name} chose #{computer.move}"
  end

  def display_round_winner
    h_move = human.move
    c_move = computer.move
    if h_move > c_move
      puts "#{h_move.to_s.capitalize} beats #{c_move} \n" \
           "#{human.name} gains one point!"
    elsif c_move > h_move
      puts "#{c_move.to_s.capitalize} beats #{h_move} \n" \
           "#{computer.name} gains one point!"
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

  def press_any_key(message)
    puts "Press enter to #{message}"
    gets.chomp
  end

  def resolve_match
    display_moves
    loading
    display_round_winner
    puts
    award_point
    display_score
  end

  def match
    system 'clear'
    display_score
    human.choose
    computer.choose
    history.record_move
    resolve_match
    loading
    press_any_key('continue')
  end

  def resolve_round
    display_winner
    history.record_round_winner(match_winner)
    history.record_match
    history.move_history_interface
    human.reset_score
    computer.reset_score # may no longer be useful
    change_challenger
    history.change_computer(computer)
  end

  def change_challenger
    old_challenger = @computer

    loop do
      @computer = [R2d2.new, Hal.new, Chappie.new, Sonny.new,
                   Number5.new].sample
      break unless @computer == old_challenger
    end
  end

  def play
    loop do
      press_any_key('start')
      loop do
        match
        break if win_condition?
      end
      resolve_round
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
