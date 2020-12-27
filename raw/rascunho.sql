
with payables_cte as(
	select transaction_id as transaction_id_p , abs(fee) as mdr_fee
	from(
		select type, row_number() over (PARTITION by transaction_id order by (payable_created_at, installment) desc) as RN, *	
		from payables p 
	) X
	where X.RN =1)
	
	,transactions_cte as(
		select transaction_id as transaction_id_t
		,company_id
		,payment_method
		,amount as transaction_amount
		,gateway_fee
		,case when transaction_installments = 1 then 'a vista' 
   			when transaction_installments between 2 and 6 then '2-6'
			when transaction_installments between 7 and 12 then '7-12'
    	 end installments_range
    	 from  transactions
    	 where payment_method like '%_card') 
    	 
	,transactionops_cte as (
		select 	
				type as financial_operation_type
				,transaction_id
				,acquirer_name
				,transaction_created_at::time as created_at , transaction_created_at::date as date
				,to_char(transaction_created_at,'month') as month_name,extract (dow from transaction_created_at) as day_of_week
				
		from ( select  transaction_operation_created_at - '3 hour'::interval  as transaction_created_at, *
				from "transactionOperations" to2 
			    where  (to2.type = 'capture' or to2.type = 'refund' or  to2.type = 'chargeback_refund' or to2.type = 'chargeback') and status = 'success'
			   ) x
	)
		
	, companies_cte as(
	 	select company_id as company_id_c, company_mcc, company_type from companies 
	)
	
	
select 
		case when (A.financial_operation_type = 'refund') or (A.financial_operation_type= 'chargeback') then -1*C.transaction_amount else C.transaction_amount end transaction_amount
		,case when (A.financial_operation_type = 'refund') or (A.financial_operation_type ='chargeback') then -B.mdr_fee else B.mdr_fee end mdr_fee
	   	,case when (A.financial_operation_type = 'refund') or (A.financial_operation_type= 'chargeback') then 0 else C.gateway_fee end gateway_fee
		,A.transaction_id, C.payment_method
		,C.installments_range, A.financial_operation_type, A.created_at, A.date , A.day_of_week
		,C.company_id, C.company_mcc, C.company_type
		,case when  B.mdr_fee isnull then 'gateway' else 'psp' end product_name
		,A.acquirer_name
	   
from transactionops_cte A
left join payables_cte B
	on A.transaction_id = B.transaction_id_p 
inner join (select * from transactions_cte X inner join companies_cte Y on X.company_id = Y.company_id_c ) C
	on A.transaction_id = C.transaction_id_t
order by A.transaction_id 




--select * from transactions t2 where transaction_id = 'e9d9d6385f' 

--select * from "transactionOperations" to2  where transaction_id = 'e9d9d6385f'

--select * from payables p  where transaction_id = 'e9d9d6385f'

--select * from transactions 

--select * from "transactionOperations" 

----------------------------------------------------------------------------