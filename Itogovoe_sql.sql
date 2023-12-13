--Задание 1
--Вывести список сотрудников старше 65 лет.
select 
 concat(p.last_name,' ',p.first_name,' ',p.middle_name) as "fio",
 p.dob,
 date_part('year', age(p.dob)) as "years"
from hr.person p 
where date_part('year', age(p.dob))> 65

--Задание 2
--Вывести количество вакантных должностей.
select
 count(1)
from vacancy v
where v.closure_date is null

--Задание 3
--Вывести список проектов и количество сотрудников, задействованных на этих проектах.
select 
 p."name",
 p.employees_id,
 p.assigned_id,
 cardinality(p.employees_id) as "emp_count"
from projects p 

--Задание 4
--Получить список сотрудников у которых было повышение заработной платы на 25%
with e4 as (select 
 es.emp_id,
 es.salary,
 (lead(es.salary, 1) OVER (ORDER BY es.emp_id)) as "prev_salary",
 round((((es.salary - (lead(es.salary, 1) OVER (ORDER BY es.emp_id)))/(lead(es.salary, 1) OVER (ORDER BY es.emp_id))) * 100),0) as "change_percent"
from employee_salary es )
select * from e4
where "change_percent" = 25

--Задание 5
--Вывести среднее значение суммы договора на каждый год, округленное до сотых.
select 
 date_part('year', created_at) as "year",
 round(avg(amount),2) as "avg_amount"
from projects p
group by "year"

--Задание 6
--Одним запросом вывести ФИО сотрудников с самым низким и самым высоким окладами за все время.
with e6 as(
 select 
  concat(p.last_name,' ',p.first_name,' ',p.middle_name) as "fio",
  es.salary as "salary"
 from employee_salary es,person p, employee e
 where 
  es.emp_id = e.emp_id
  and e.person_id = p.person_id
)
select *
from e6
where 
 "salary" = (select max("salary")from e6)
 or "salary" = (select min("salary")from e6) 
 
--Задание 7
--Вывести текущий оклад сотрудников и в формате строки вывести зарплатные грейды, в которые попадает текущий оклад.
select 
 es.emp_id,
 es.salary,
 array_to_string(array_agg(gs.grade), ', ') as grades_as_string
from employee_salary es, grade_salary gs
where es.salary >= gs.min_salary or es.salary >= gs.max_salary
group by es.emp_id,es.salary