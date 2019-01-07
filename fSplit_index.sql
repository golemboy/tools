CREATE FUNCTION [dbo].[fSplit_index]( @Value varchar(8000), @Delimiter varchar(10)=',', @trim bit = 1)
RETURNS @result TABLE (value Varchar(500), idx int)
AS
BEGIN
 
	;with cte(idx, left_value, right_value) as (
		select CHARINDEX(@Delimiter,@Value,0) as idx		
		, LEFT(@Value,CHARINDEX(@Delimiter,@Value,0) - 1 ) as left_value
		, SUBSTRING(@Value,CHARINDEX(@Delimiter,@Value,0 )+1,len(@Value)) as right_value
		UNION ALL
		select CHARINDEX(@Delimiter,@Value,cte.idx+1) as idx
		, case when CHARINDEX(@Delimiter,right_value,0) > 0 then LEFT(right_value,CHARINDEX(@Delimiter,right_value,0) -1  ) else right_value end as left_value	
		, case when CHARINDEX(@Delimiter,right_value,0 ) < len(right_value) AND CHARINDEX(@Delimiter,right_value,0 ) > 0 then SUBSTRING(right_value,CHARINDEX(@Delimiter,right_value,0 )+1, len(right_value) ) else '' end as right_value
		from cte
		where idx > 0
	), cta as (
		select case when idx> 0 then idx else len(@Value) end as idx, left_value	as value	
		from cte
	)
	INSERT INTO @result(idx, value) 
	select idx, value
	from cta
	where @trim  = 0 OR (@trim = 1 and  NULLIF(ltrim(rtrim(value)),'') is not null)
  
	RETURN

END
