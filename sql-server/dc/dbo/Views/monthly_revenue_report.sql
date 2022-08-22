CREATE VIEW [dbo].[monthly_revenue_report]
	AS SELECT [month], [merchant_reference]
		,SUM(sum_of_gross_sales) as sum_of_gross_sales
		,SUM(sum_of_refund_amount) as sum_of_refund_amount
		,SUM(sum_of_refund_reversed) as sum_of_refund_reversed
		,SUM(sum_of_fee) as sum_of_fee
		,SUM(sum_of_refund_fee) as sum_of_refund_fee
		,SUM(sum_of_transaction_costs) as sum_of_transaction_costs
		,SUM(sum_of_chargeback_fee) as sum_of_chargeback_fee
		,SUM(sum_of_chargeback) as sum_of_chargeback
		,SUM(sum_of_chargeback_reversed) as sum_of_chargeback_reversed
		,SUM(sum_of_invoice_deduction) as sum_of_invoice_deduction
		,SUM(sum_of_balance_transfer) as sum_of_balance_transfer
		,SUM(sum_of_deposit_correction) as sum_of_deposit_correction
		,SUM(sum_of_net_payout) as sum_of_net_payout
FROM
(SELECT format([payment_received_date],'yyyy-MM-01') as [month], [merchant_reference], [type]
      ,CASE WHEN [type] != 'MerchantPayout' THEN SUM(IsNull([net_credit], 0))- SUM(IsNull([net_debit], 0)) END as sum_of_net_payout

	  ,CASE WHEN [type] = 'Settled' THEN SUM(IsNull([commission], 0)) + SUM(IsNull([markup], 0)) + SUM(IsNull([scheme_fees], 0)) + SUM(IsNull([interchange], 0)) END as sum_of_transaction_costs
	  ,CASE WHEN [type] = 'Settled' THEN SUM(IsNull(gross_credit, 0)*exchange_rate) - SUM(IsNull(gross_debit, 0)*exchange_rate) END as sum_of_gross_sales

	  ,CASE WHEN [type] = 'Refunded' THEN SUM(gross_debit*exchange_rate) END as sum_of_refund_amount
	  ,CASE WHEN [type] = 'Refunded' THEN SUM(IsNull([commission], 0)) + SUM(IsNull([markup], 0)) + SUM(IsNull([scheme_fees], 0)) + SUM(IsNull([interchange], 0)) END as sum_of_refund_fee

	  ,CASE WHEN [type] = 'RefundedReversed' THEN SUM(gross_credit*exchange_rate) END as sum_of_refund_reversed

	  ,CASE WHEN [type] = 'Fee' THEN SUM([net_debit]) END as sum_of_fee

	  ,CASE WHEN [type] = 'Chargeback' THEN SUM(IsNull([commission], 0)) + SUM(IsNull([markup], 0)) + SUM(IsNull([scheme_fees], 0)) + SUM(IsNull([interchange], 0)) END as sum_of_chargeback_fee
	  ,CASE WHEN [type] = 'Chargeback' THEN SUM(gross_debit*exchange_rate) END as sum_of_chargeback

	  ,CASE WHEN [type] = 'ChargebackReversed' THEN SUM([net_credit]) END as sum_of_chargeback_reversed

	  ,CASE WHEN [type] = 'InvoiceDeduction' THEN SUM(IsNull([net_credit], 0))- SUM(IsNull([net_debit], 0)) END as sum_of_invoice_deduction

	  ,CASE WHEN [type] = 'Balancetransfer' THEN SUM(IsNull([net_credit], 0))- SUM(IsNull([net_debit], 0)) END as sum_of_balance_transfer

	  ,CASE WHEN [type] = 'DepositCorrection' THEN SUM([net_debit]) END as sum_of_deposit_correction

  FROM [dbo].[payments_info]
  GROUP BY format([payment_received_date],'yyyy-MM-01'), [merchant_reference], [type]) as numbers_on_month_id_type
  GROUP BY [month], [merchant_reference]
