require "sqlite3"
DB = SQLite3::Database.new("medical_appointment.db")
DB.results_as_hash = true

def free_slots(date)
  # Getting all appointments and opening_times
  opening_times = DB.execute("SELECT * FROM doctors_working_hours")
  appointments = DB.execute("SELECT * FROM appointments")

  # Extracting start_time of every appointment and putting it into an array
  appointment_times = []
  appointments.select { |appointment| appointment_times << Time.parse(appointment["appointment_start_time"]).strftime("%Y-%m-%d %k:%M").strip }

  # Creating available_slots hash this is the result we want to return
  available_slots = {}
  # 60 * 15 = 900 seconds - duration of every appointment
  appointment_duration = 900
  # Converting input into date
  start_date = Date.parse(date) # 2022-12-08

  # Getting opening times for 7 days from a given date
  filtered_days = opening_times.select { |day| Date.parse(day["start_time"]) if Date.parse(day["start_time"]) >= start_date }
  filtered_days.first(7)

  # Iterating through every day
  filtered_days.first(7).each do |day|
    # Calculating doctor's availability on one selected day
    start_time = (DateTime.parse(day["start_time"])).to_time
    end_time = (DateTime.parse(day["end_time"])).to_time

    # Creating an array for available slots which will be populated later
    slots_arr = []


    # Iterating through all time slots on one given day
    while start_time < end_time

      # Checking if a current slot is already booked
      isBooked = appointment_times.include?(start_time.strftime("%Y-%m-%d %k:%M").strip)

      if isBooked
        start_time += appointment_duration
      else
        slots_arr << { "start_time": start_time, "end_time": start_time + appointment_duration }
        start_time += appointment_duration
      end


    end

    available_slots[day["day_of_week"]] = slots_arr

  end

  # Return the hash with available slots during next 7 days
  available_slots

end

puts free_slots('2022-12-05')
