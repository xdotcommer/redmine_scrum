class SprintAverage < SprintStat
  METHODS = %w(completed_points completed_stories committed_stories committed_points distractions reopens defects bugs).map(&:to_sym)

  METHODS.each do |m|
    define_method(m) do
      sprints.average(m).round.to_i
    end
  end

  def to_json
    hash = {}

    METHODS.each do |key|
      hash[key] = send(key)
    end

    hash[:start_date] = start_date

    hash.to_json
  end
end