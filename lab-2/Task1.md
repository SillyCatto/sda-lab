
### Task 1 

- **Dimension tables**
	- `dim_time` — primary key: `time_id`
	- `dim_driver` — primary key: `driver_id`
	- `dim_circuit` — primary key: `circuit_id`
	- `dim_race` — primary key: `race_id`

- **Fact tables**
	- `fact_race_performance` — primary key: `performance_id`

- **Foreign keys (in `fact_race_performance`)**
	- `time_id` -> `dim_time.time_id`
	- `driver_id` -> `dim_driver.driver_id`
	- `circuit_id` -> `dim_circuit.circuit_id`
	- `race_id` -> `dim_race.race_id`

