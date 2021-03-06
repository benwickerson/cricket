class Over < GameComponents
  attr_accessor :facing_b, :non_striker
  attr_reader :balls, :o_runs, :wickets, :bowler, :ball, 
    :over_id, :score, :innings_over, :ball_in_over, :batting_team

  def initialize(innings, bowler, current_batter_1, current_batter_2, over_id, batting_team, target, score, wickets, fielding_team)
    @innings        = innings
    @balls          = []
    @o_runs         = 0
    @wickets        = 0
    @total_wickets  = wickets
    @score          = score
    @target         = target
    @bowler         = bowler
    @facing_b       = current_batter_1
    @non_striker    = current_batter_2
    @batting_team   = batting_team
    @fielding_team  = fielding_team
    @over_id        = over_id
    @ball           = nil
    @innings_over   = false
    @ball_in_over   = nil
    @bowler.stats_bowling[@innings][:overs] += 1
  end

  def run_over
    over_heading
    @ball_in_over = 1
    while @balls.length < 6 do 
      @ball = Delivery.new(@innings, @ball_in_over, @bowler, @facing_b, @non_striker, @fielding_team)
      @ball.bowl_ball(@innings)
      @balls << @ball
      runs_in_over
      check_for_wicket 
      check_for_end_of_innings
      if @innings_over == true
        break
      end
      @ball_in_over += 1
      facing
    end
    check_for_maiden
  end

  def runs_in_over
    @o_runs += @ball.runs_scored
    @score += @ball.runs_scored
  end

  def check_for_maiden
    if @o_runs == 0
      @bowler.stats_bowling[@innings][:maidens] += 1
    end
  end

  def check_for_wicket
    if @ball.facing_batsman.stats_batting[@innings][:out] == true
      @wickets += 1
      how_out(@facing_b, @bowler, @fielding_team, @innings)
      @total_wickets += 1
      @batting_team.players.each do |batter|
        if batter.stats_batting[@innings][:out] == false && batter.stats_batting[@innings][:batted] == false
          @facing_b = batter
          batter.stats_batting[@innings][:batted] = true
          break
        end
      end
      #@batting_team.score[@total_wickets.to_s.to_sym] = @score
    end
  end

  def check_for_end_of_innings
    total_wickets = 0
    @batting_team.players.each do |batter|
      if batter.stats_batting[@innings][:out] == true
        total_wickets += 1
      end
    end
    if total_wickets == 10
      @innings_over = true
    end
    if @target > 0 && @target < @score
      @innings_over = true
    end
  end

  def facing
    old_face     = @facing_b
    new_face     = @non_striker 
    if @ball.runs_scored % 2 != 0
      @facing_b     = new_face
      @non_striker  = old_face
    end
  end
end