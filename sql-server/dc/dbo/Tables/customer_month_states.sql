CREATE TABLE [dbo].[customer_month_states]
(
    [customer_id] UNIQUEIDENTIFIER NOT NULL,
    [month]      DATETIME           NOT NULL,
	[channel] VARCHAR(3) NULL,
	[cohort] CHAR(7) NOT NULL,
	[age] INT NOT NULL,
	[new_customer] BIT NOT NULL,
	[is_active] BIT NOT NULL,
	[has_new_subscription] BIT NOT NULL,
	[is_trialist] BIT NOT NULL,
	[is_reconnect] BIT NOT NULL,
	[is_paying] BIT NOT NULL,
	[has_chargeback] BIT NOT NULL,
	[has_reversed_chargeback] BIT NOT NULL,
	[has_refund] BIT NOT NULL,
	[currency] CHAR(3) NOT NULL,
	[gross_debit] SMALLMONEY NOT NULL,
	[gross_credit] SMALLMONEY NOT NULL,
	[gross_received] SMALLMONEY NOT NULL,
	[net_debit] SMALLMONEY NOT NULL,
	[net_credit] SMALLMONEY NOT NULL,
	[net_received] SMALLMONEY NOT NULL,
	[commission] SMALLMONEY NOT NULL,
	[markup] SMALLMONEY NOT NULL,
	[scheme_fees] SMALLMONEY NOT NULL,
	[interchange] SMALLMONEY NOT NULL,
	[total_fees] SMALLMONEY NOT NULL,
	[gross_debit_total] SMALLMONEY NOT NULL,
	[gross_credit_total] SMALLMONEY NOT NULL,
	[gross_received_total] SMALLMONEY NOT NULL,
	[net_debit_total] SMALLMONEY NOT NULL,
	[net_credit_total] SMALLMONEY NOT NULL,
	[net_received_total] SMALLMONEY NOT NULL,
	[commission_total] SMALLMONEY NOT NULL,
	[markup_total] SMALLMONEY NOT NULL,
	[scheme_fees_total] SMALLMONEY NOT NULL,
	[interchange_total] SMALLMONEY NOT NULL,
	[total_fees_total] SMALLMONEY NOT NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    PRIMARY KEY CLUSTERED ([customer_id] ASC, [month] ASC)
);

GO
	CREATE TRIGGER [trgAfterUpdateCustomerMonthStates]
		ON [dbo].[customer_month_states]
		FOR INSERT
		AS
		UPDATE [dbo].[customer_month_states]
		  SET [updated] = GETUTCDATE()
		  FROM [customer_month_states] t
		  INNER JOIN inserted i on t.[customer_id] = i.[customer_id] AND t.[month] = i.[month]
