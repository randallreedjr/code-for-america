require 'pry'
class Census
  def initialize(file_name)
    @file_name = file_name
  end

  def read
    headers = []
    places = {}
    # {
    #   00562 => {
    #   area: 982120,
    #   population: 3497,
    #   housing: 1450
      # }
    # }
    File.open(@file_name, 'r') do |file_reader|
      while line = file_reader.gets
        if headers.empty?
          headers = line.chomp.split("\t")
          place_index = headers.index('Place FIPS')
          area_index = headers.index('Land Area')
          population_index = headers.index('Population')
          housing_index = headers.index('Housing Units')
        else
          values = line.chomp.split("\t")
          place = values[place_index]
          area = values[area_index].to_i
          population = values[population_index].to_i
          housing = values[housing_index].to_i
          if places[place]
            places[place][:area] += area.to_f
            places[place][:population] += population
            places[place][:housing] += housing
          else
            places[place] = {area: area.to_f, population: population, housing: housing}
          end
        end
      end
    end
    places = places.sort_by{ |place,data| data[:population]/data[:area] }

    puts "\nResults are lists from sparsest (#{places.first[0]}) to densest (#{places.last[0]}):\n"
    places.to_h.each_pair do |place, data|
      puts "Place: #{place}"
      puts "Area: #{data[:area].to_i}"
      puts "Total Population: #{data[:population]}"
      puts "Total Housing: #{data[:housing]}"
      puts "Population Density: #{calculate_density(data[:population], data[:area])}"
      puts "Housing Density: #{calculate_density(data[:housing], data[:area])}\n\n"
    end
  end

  def calculate_density(value, area)
    (value / area).round(6)
  end
end

census = Census.new('tracts.txt')
census.read