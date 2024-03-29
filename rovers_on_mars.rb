def navigate_rovers(plateau_size, rovers)
  # Yes, "plateau_size" is not the best name.
  unless plateau_size.keys.sort == [:h, :w] &&
         plateau_size[:w].is_a?(Integer) &&
         plateau_size[:h].is_a?(Integer)
    puts 'Wrong plateau size format.'
    return
  end

  unless rovers.map { |rover| rover[:start_position].fetch_values(:x, :y) }.length ==
          rovers.map { |rover| rover[:start_position].fetch_values(:x, :y) }.uniq.length
    puts 'Multiple rovers could not have the same start positions.'
    return
  end

  left_directions = ['N', 'E', 'S', 'W'].freeze
  right_directions = left_directions.reverse.freeze

  rovers_positions = []

  rovers.each do |rover|
    unless rover[:start_position].keys.sort == [:direction, :x, :y] &&
           rover[:start_position][:x].is_a?(Integer) &&
           rover[:start_position][:y].is_a?(Integer) &&
           left_directions.include?(rover[:start_position][:direction])
      rovers_positions << nil
      next
    end

    current_position = rover[:start_position].clone

    rover[:instructions].each do |inst|
      next unless ['L', 'R', 'M'].include?(inst)

      current_direction = current_position[:direction]
      next_position = current_position.clone

      case inst
      when 'L'
        current_position[:direction] = left_directions[left_directions.index(current_direction) - 1]
      when 'R'
        current_position[:direction] = right_directions[right_directions.index(current_direction) - 1]
      when 'M'
        case current_position[:direction]
        when 'N'
          next_position[:y] += 1
        when 'E'
          next_position[:x] += 1
        when 'S'
          next_position[:y] -= 1
        when 'W'
          next_position[:x] -= 1
        end

        # Don't move the current rover to a cell occupied by one of the previously moved rovers.
        unless rovers_positions.compact.map { |p| p.fetch_values(:x, :y) }.include?(next_position.fetch_values(:x, :y))
          # Don't move the current rover outside of the plateau.
          current_position[:x] = (0..plateau_size[:w]).include?(next_position[:x]) ? next_position[:x] : current_position[:x]
          current_position[:y] = (0..plateau_size[:h]).include?(next_position[:y]) ? next_position[:y] : current_position[:y]
        end
      end
    end

    rovers_positions << current_position
  end

  p rovers_positions
end
