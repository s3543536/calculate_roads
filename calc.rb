require 'csv'
require 'json'

class JSONable
	def to_json
		return self.to_hash.to_json
	end

	def to_hash
		hash = {}
		self.instance_variables.each do |var|
			if(var.is_a?(JSONable))
				hash[var] = self.instance_variable_get(var).to_hash
			else
				hash[var] = self.instance_variable_get(var)
			end
		end
		return hash
	end


	def from_json!(string)
		JSON.laod(string).each do |var, val|
			self.instance_variable_set(var, val)
		end
	end
end

class AvgNum < JSONable
	@max = 0.0
	@min = 0.0
	@avg = 0.0
	@med = (@max + @min)/2

	attr_accessor :max, :min, :avg

	#def to_json
		#return {'max' => @max, 'min' => @min, 'avg' => @avg, 'med' => @med}.to_json
	#end

	#def from_json(string)
		#data = JSON.parse(string)
		#self.new(data['max'], data['min'], data['avg'])
	#end

	def med
		return @med
	end

	def med=(trash)
		calc_med()
	end

	def initialize(max, min = nil, avg = nil)
		@max = max
		if(min.nil?)
			@min = max
			@avg = max
			@med = max
		else
			@min = min
			@avg = avg
			calc_med()
		end
	end

	def calc_med()
		@med = (@max + @min)/2
	end
end

class Place < JSONable
	@name = ""
	@population = 0
	@vehicle_count = 0
	# metres squared
	@vehicle_space = 0
	# seconds
	@travel_time = 0

	attr_accessor :name, :population, :vehicle_count, :vehicle_space, :travel_time
end

def calc_congestion_index(people, vehicles, space, time)
	return (people * space) / (vehicles * time)
end

def calc_vehicle_space(vehicle_count, space_per_vehicle)
	return vehicle_count * space_per_vehicle
end

def calc_person_space_in_vehicle(person_count, space_per_vehicle)
	return space_per_vehicle / person_count
end

@infile = './in'

def start

	if(ARGV[0] == 'make_template')
		melbourne = Place.new()
		melbourne.name = 'Melbourne'
		melbourne.population = 4480000
		melbourne.vehicle_count = 3360000
		melbourne.vehicle_space = AvgNum.new(11.016, 2.022, (11.016+8.789+5.69+2.022)/4)
		melbourne.travel_time = 1590 #AvgNum.new(1590)

		puts JSON.generate(melbourne)

		puts melbourne.to_json

		open('./example', 'w') do |file|
			file.write(melbourne.to_json)
		end
		return
	end

	file = open('./jsonfile.json')
	json = file.read
	data = JSON.parse(json)
end

start
