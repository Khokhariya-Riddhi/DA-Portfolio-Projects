use loan_project;

CREATE TABLE loan_data (
    loan_id               INT PRIMARY KEY,
    no_of_dependents      INT,
    education             VARCHAR(20),
    self_employed         VARCHAR(5),
    income_annum          BIGINT,
    loan_amount           BIGINT,
    loan_term             INT,
    cibil_score           INT,
    residential_assets_value  BIGINT,
    commercial_assets_value   BIGINT,
    luxury_assets_value       BIGINT,
    bank_asset_value          BIGINT,
    loan_status           VARCHAR(10),
    total_assets          BIGINT,
    loan_to_income        DOUBLE,
    cibil_band            VARCHAR(15),
    loan_to_assets        DOUBLE,
    estimated_monthly_repayment          DOUBLE,
    emi_to_income         DOUBLE,
    income_bracket        VARCHAR(10),
    loan_size_bracket     VARCHAR(10),
    loan_to_income_band     VARCHAR(10),
    loan_to_assets_band     VARCHAR(10)
);

select * from loan_data limit 10;

-- Q-1 Overall approval rate
select 
loan_status ,
count(*) as total,
round(count(*) / (select  count(*) from loan_data) * 100,2) as percentage 
from loan_data
group by loan_status ;

-- Q-2 Single Factor Analysis
--  Why 37.78 % got rejected? Which Factors affecting loan rejection ?
-- check rejection per factor

-- 2a: Rejection by each CIBIL band
select
  cibil_band,
  COUNT(*) AS total_applications,
  SUM(CASE when loan_status = 'Rejected' then 1 else 0 END) AS rejected,
  ROUND(SUM(CASE when loan_status = 'Rejected' then 1 else 0 END) / COUNT(*) * 100, 2) AS rejection_rate
FROM loan_data
GROUP BY cibil_band
ORDER BY rejection_rate DESC;


-- 2b: Rejection by loan_amount / loan size bracket

-- select 
-- l1.loan_size_bracket ,
-- (select count(*) from loan_data where loan_size_bracket =l1.loan_size_bracket )as total_loans ,
-- (select count(*) from loan_data where loan_status ="Rejected" and loan_size_bracket =l1.loan_size_bracket  )as rejected_loans,
-- round(
--  (select count(*)from loan_data where loan_status ="Rejected" and loan_size_bracket =l1.loan_size_bracket )/
--  (select count(*) from loan_data where loan_size_bracket =l1.loan_size_bracket )*100,2)as rejection_rate
-- from loan_data l1
-- group by loan_size_bracket 
-- order by loan_size_bracket desc

select 
loan_size_bracket ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by loan_size_bracket;


-- 2c: Rejection by employment type
select 
self_employed,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by self_employed; 

-- 2d: Rejection by education
select 
education,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by education; 

-- 2e: Rejection by income bracket
select 
income_bracket,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by income_bracket;

-- 2f: Rejection by loan_to_income ratio
select 
loan_to_income_band,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by loan_to_income_band;


-- 2g: Rejection by loan_to_assets ratio
select 
loan_to_assets_band,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by loan_to_assets_band;

-- 2h: Rejection by dependents
select 
no_of_dependents ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by no_of_dependents 
order by no_of_dependents;


-- 2i: Rejection by loan terms
select 
loan_term  ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by loan_term  
order by loan_term ;


-- 2j: Rejection by estimated monthly repayment burden
select 
case 
	when emi_to_income is null then 'Unknown'
	when emi_to_income < 0.20 then '1 - Low Burden(< 20%)'
	when emi_to_income between  0.20 and 0.40 then '2 - Medium Burden(20-40 %)'
	else '3 -High Burden (>40%)'
end as repayment_burden,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by repayment_burden  
order by repayment_burden ;


-- Q - 3 Most influential factors in loan rejection 
--  loan_amount or loan_size_bracket , income_bracket , loan_to_assets 

-- 3a: Risk Factor Ranking by Observed rejection rate 
select 
'Poor CIBIL Score' as risk_factor,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as Rejection_Rate
from loan_data 
where cibil_band ='Poor'
union all                                                  
select 
'Low Income' ,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where income_bracket ='Low'
union all                                                       
select 
'Repayment Burden',
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where emi_to_income >0.40
union all                                                       
select 
'High Loan-to-Assets',
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where loan_to_assets_band ='High'
union all                                                       
select 
'High Loan-to-Income' ,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where loan_to_income_band ='High'
union all                                                       
select 
'Self Employed' ,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where self_employed ='Yes'
union all                                                       
select 
'Education - Not Graduate' ,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)
from loan_data 
where education ='Not Graduate'
order by Rejection_Rate desc;

-- 3b: rejection rate by all CIBIL band & all income level
select 
cibil_band ,income_bracket ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
group by cibil_band ,income_bracket 
order by 
case
	when cibil_band ='Poor' then 1
	when cibil_band ='Fair' then 2
	when cibil_band ='Good' then 3
	when cibil_band ='Excellent' then 4
end,
case
	when income_bracket ='Low' then 1
	when income_bracket ='Medium' then 2
	when income_bracket ='High' then 3
end; 

-- 3c: poor cibil: rejection rate by loan_amount
select 
loan_size_bracket ,cibil_band ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
where cibil_band ='Poor'
group by loan_size_bracket ,cibil_band
order by loan_size_bracket desc,cibil_band desc;


-- 3d: poor cibil: rejection rate by income_bracket
select 
income_bracket  ,cibil_band ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
where cibil_band ='Poor'
group by income_bracket  ,cibil_band
order by income_bracket  desc,cibil_band desc;


-- 3e: poor cibil: rejection rate by loan_to_assets band
select 
loan_to_assets_band ,cibil_band ,
count(*) as total_loan,
sum(case
	when loan_status ='Rejected' then 1
	else 0
end )as rejected_loan,
ROUND(
(sum(case
	when loan_status ='Rejected' then 1
	else 0
end )/count(*))*100,2)as rejection_rate
from loan_data
where cibil_band ='Poor'
group by loan_to_assets_band   ,cibil_band
order by loan_to_assets_band   desc,cibil_band desc;


-- Q - 4 High Approval Profile Analysis
select 
cibil_band ,income_bracket ,loan_size_bracket ,
count(*) as total_loan,
sum(case
	when loan_status ='Approved' then 1
	else 0
end )as approved_loan,
ROUND(
(sum(case
	when loan_status ='Approved' then 1
	else 0
end )/count(*))*100,2)as approval_rate
from loan_data
group by cibil_band,income_bracket ,loan_size_bracket
having total_loan >=30 and approval_rate >=90
order by approval_rate desc;


-- Q - 5 Borderline rejections
select 
cibil_band ,income_bracket ,loan_size_bracket ,loan_to_assets_band, 
count(*) as borderline_rejection
from loan_data
where loan_status ='Rejected' and cibil_band in ('Fair','Good')
group by cibil_band,income_bracket ,loan_size_bracket ,loan_to_assets_band 
order by borderline_rejection desc;     

