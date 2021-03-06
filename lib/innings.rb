class Innings < GameComponents
  attr_accessor :score, :wickets, :current_over, :partnership
  attr_reader :innings, :batting_team, :fielding_team, :total_overs, :name, :over_decimal

  def initialize(innings, batting_team, fielding_team, total_overs, target = 0)
    @batting_team     = batting_team
    @fielding_team    = fielding_team
    @total_overs      = total_overs
    @target           = target
    @facing_b         = @batting_team.players[0]
    @non_striker      = @batting_team.players[1]
    @score            = 0
    @wickets          = 0
    @current_over     = nil
    @current_over_num = 1
    @current_bowler   = nil
    @all_bowlers      = []
    @batted_batters   = []
    @bowled_bowlers   = []
    @innings          = innings
    @overs_array      = []
    all_bowlers
    @innings_name     = "#{@innings + 1} - #{@batting_team.team_name}"
    @batting_team.players.each do |pl|
      pl.stats_batting =  { @innings => {
        batted:       false,
        balls_faced:  0, 
        dot_balls:    0,  
        runs_scored:  0,
        fours_hit:    0,
        sixes_hit:    0,
        out:          false,
        howout:       "Not out",
        wicket_taker: ""
        }
      }
    end
    @fielding_team.players.each do |pl|
      pl.stats_bowling = { @innings => {
        overs:        0,
        deliveries:   0, 
        maidens:      0,
        runs_scored:  0,
        wickets:      0,
        wides:        0,
        no_balls:     0,
        runs:         0
        }
      }
    end
    @fielding_team.players.each do |pl|
      pl.stats_fielding = { @innings => {
        catches:      0,
        stumpings:    0,
        run_outs:     0
        }
      }
    end
    @facing_b.stats_batting[@innings][:batted]       = true
    @non_striker.stats_batting[@innings][:batted]    = true 
  end

  def run_innings
    innings_header
    run_overs
    end_of_innings_stats(@innings)
  end

  def run_overs
    catch (:in_over) do
      @total_overs.times do
        pick_bowler
        new_over
        @current_over.run_over
        @overs_array << @current_over
        new_score
        if @current_over.innings_over == true
          throw :in_over
        end
        close_over
      end
    end
    batters_who_batted
    bowlers_who_bowled
    overs_decimal
  end

  def close_over
    show_over_summary
    @current_over_num += 1
    facing
  end

  def new_over
    @current_over = Over.new(@innings, @current_bowler, @facing_b, @non_striker, @current_over_num, @batting_team, @target, @score, @wickets, @fielding_team)
  end

  def new_score
    @score = @current_over.score
    @wickets = @wickets + @current_over.wickets
  end

  def all_bowlers
    @fielding_team.players.each do |pl|
      if pl.type == "Bowler" || pl.type == "All Rounder"
        @all_bowlers << pl
      end
    end
  end

  def pick_bowler
    potential_bowlers = []
    @fielding_team.players.each do |pl|
      if pl.type == "Bowler" || pl.type == "All Rounder"
        potential_bowlers << pl
      end
    end
    potential_bowlers.delete(@current_bowler)
    @current_bowler = potential_bowlers.sample 
  end

  def facing
    @non_striker = @current_over.facing_b
    @facing_b = @current_over.non_striker
  end

  def batters_who_batted
    @batting_team.players.each do |pl|
      if pl.stats_batting[@innings][:batted] == true && pl.stats_batting[@innings][:balls_faced] > 0
        @batted_batters << pl
      end
    end
  end

  def bowlers_who_bowled
    @all_bowlers.each do |bowler|
      if bowler.stats_bowling[@innings][:overs] > 0
        @bowled_bowlers << bowler
      end
    end
  end

  def overs_decimal
    if @current_over.ball_in_over == 7
    @over_decimal = "#{@current_over_num - 1}"
    else  
    @over_decimal = "#{@current_over_num - 1}.#{@current_over.ball_in_over}"
    end
  end

end