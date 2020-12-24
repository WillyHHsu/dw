select * from payables p 

select * from companies c 

select * from "transactionOperations" to2 

select * from transactions t 



select t.transaction_id , gateway_fee, *
from transactions t
join "transactionOperations" tops
	on t.transaction_id = tops.transaction_id
where payment_method like '%_card'



--olhando para um cara só

select fee as mdr, * 
from payables p
where payment_method like '%_card'
and transaction_id ='bbe13c364b'


select * 
from transactions t
where transaction_id ='bbe13c364b'

select * 
from "transactionOperations" to2 
where transaction_id ='bbe13c364b'

select status, case  when acquirer_name='pagarme' then 'psp' else 'gateway' end teste, *
from transactions t



--

with payables_cte as(
	select case when installment = 1 then 'a vista' 
		   		when installment between 2 and 6 then '2-6'
				when installment between 7 and 12 then '7-12'
		    end installment_buckets
			, *
	from(
		select type, row_number() over (PARTITION by transaction_id order by (payable_created_at, installment) desc) as RN, *	
		from payables p 
	) X
	where X.RN =1)


--- olhando 
select  *	
from payables p
order by transaction_id, installment 
