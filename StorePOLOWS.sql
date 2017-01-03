--[dbo].[GrabaBillingWS]
use [OLO]
go

declare @cad varchar(50)
set  @cad='0123'-- @cad='0123|4567'

declare @pval varchar(20),@sval varchar(20)

select @cad,substring(@cad,0,charindex('|',@cad)),reverse( substring(reverse(@cad),0,charindex('|',reverse(@cad))))

declare @scad varchar(50)
set @scad=null

select charindex('|',@scad)

declare @MAC varchar(50)

set @MAC='|32'

If charindex('|',@MAC) >0
Begin 
	select 'ingreso'		
End


CREATE PROCEDURE [dbo].[GrabaBillingWSNvNv]

@IDOLOPV Varchar(50),
@IDOLOUsuario Varchar(50),
@FechaVenta Datetime,
@IDCliente Integer,
@IDTipoDocumento Integer,
@NumDocumentoCliente Varchar (20),
@NombreCliente varchar(260),
@FNacCliente Date,
@IDGeneroCliente Integer,
@OcupacionCliente VARCHAR(40),
@NacionalidadCliente VARCHAR(250),
@DireccionCliente VARCHAR(160),
@IDProvincia Integer,
@ProvinciaCliente Varchar(50),
@IDDistritoCliente Integer,
@DistritoCliente Varchar(50),
@TelefonoCliente Varchar (20),
@Celular1Cliente Varchar (15),
@Celular2Cliente Varchar (20),
@eMailCliente Varchar (80),
@DesTipoDispositivo Varchar(100),
@MAC Varchar(50),
@IDPlan Integer,
@DesPlan Varchar(100),
@IDTipoVenta Integer,
@Importe Money

AS 
BEGIN

declare @auxIDTipoDispositivo int
declare @auxDistrito varchar(50)
declare @auxProvincia varchar(50)
declare @auxPlan varchar(50)

declare @pval varchar(20),@sval varchar(20),@idbillingaux int

select @pval=substring(@MAC,0,charindex('|',@MAC))
,@sval=reverse( substring(reverse(@MAC),0,charindex('|',reverse(@MAC))))



set @auxIDTipoDispositivo = (SELECT IDTipoDispositivo FROM TblTiposDispositivo WHERE RTRIM(LTRIM(UPPER(@DesTipoDispositivo))) like '%' + UPPER(TipoDispositivo)  + ' S/N%' )
set @auxDistrito = (SELECT Distrito from TblDistritos WHERE IDDistrito = @IDDistritoCliente)

set @auxProvincia = (SELECT Provincia FROM TblProvincias WHERE @IDProvincia = IDProvincia)
set @auxPlan = (SELECT [Plan] FROM TblPlanes where IDPlan = @IDPlan)


--PROVINCIA
begin
if @auxProvincia is null and @ProvinciaCliente is not null
	INSERT INTO TblProvincias (IDProvincia,Provincia) Values (@IDProvincia,RTRIM(ltrim(@ProvinciaCliente))) 
	else
	begin
	if RTRIM(ltrim(@auxProvincia)) <> RTRIM(ltrim(@ProvinciaCliente)) and @ProvinciaCliente is not null
		UPDATE TblProvincias SET Provincia = RTRIM(ltrim(@ProvinciaCliente)) where IDProvincia = @IDProvincia
	end
end

--PLAN
begin
if @auxPlan is null and @DesPlan is not null
	INSERT INTO TblPlanes([IDPlan],[Plan]) values (@IDPlan, RTRIM(ltrim(@DesPlan)))	
	else
	begin
	if RTRIM(ltrim(@auxPlan)) <> RTRIM(ltrim(@DesPlan)) and @DesPlan is not null
		UPDATE TblPlanes SET [Plan] = RTRIM(ltrim(@DesPlan)) where IDPlan = @IDPlan
	end
end

--DISTRITO
begin
if @auxDistrito is null and @DistritoCliente is not null and @IDProvincia is not null
	INSERT INTO TblDistritos(IDDistrito, Distrito, IDProvincia) VALUES (@IDDistritoCliente,RTRIM(LTRIM(@DistritoCliente)), @IDProvincia)
	else
	begin
	if RTRIM(ltrim(@auxDistrito)) <> RTRIM(ltrim(@DistritoCliente))and @IDProvincia is not null
		UPDATE TblDistritos SET Distrito = RTRIM(ltrim(@DistritoCliente)), IDProvincia = @IDProvincia where IDDistrito = @IDDistritoCliente
	end
end

----TIPO DISPOSITIVO
--begin
--if @auxIDTipoDispositivo is null 
--	SET @auxIDTipoDispositivo = (SELECT MAX(IDTipoDispositivo) + 1 FROM TblTiposDispositivo)
--	INSERT INTO TblTiposDispositivo(IDTipoDispositivo, TipoDispositivo) VALUES (@auxIDTipoDispositivo, @DesTipoDispositivo)
--end


-- SI ES UN PACK MODIFICAMOS EL IMPORTE
BEGIN
if @IDPlan in (529,531,533,535)
	SET @Importe = 149.5
END

BEGIN
       SET NOCOUNT ON;
       -- La inserción en Billing...

--BUSCAMOS POR FECHAVENTA(solo la fecha) + IDCliente + IDTipoVenta       
declare @IDBilling int
set @IDBilling = (SELECT IDBilling FROM TblBilling
				WHERE FechaVenta = @FechaVenta
				AND IDCliente = @IDCliente
				AND IDTipoVenta = @IDTipoVenta)       

if @IDBilling is null
	BEGIN
		IF NOT( @IDTipoVenta = 1 AND (@IDPlan is null OR @Importe is null))
		--Si es una nueva venta y no indican Plan e Importe no hacemos el Insert
		BEGIN
		
			IF @IDPlan IN(553,554,555)  -- VENTA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
				SET @Importe = 50
			
			IF @IDPlan IN(556,557,558)  -- VENTA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
				SET @Importe = 0
					
			INSERT INTO TblBilling
								  (IDOLOPV, IDOLOUsuario,IDCliente, FechaVenta, IDTipoDispositivo,
								  DesTipoDispositivo, MAC, IDPlan, IDTipoVenta, Importe, IDStatusBilling)
			VALUES     
			(rtrim(ltrim(@IDOLOPV)), RTRIM(LTRIM(@IDOLOUsuario)),@IDCliente, @FechaVenta, 
								  @auxIDTipoDispositivo, 
								  RTRIM(LTRIM(@DesTipoDispositivo)),RTRIM(LTRIM(@MAC)), @IDPlan, @IDTipoVenta, @Importe, 1)

			--Adicionado***********************************************
			Set @idbillingaux=scope_identity()

			If charindex('|',@MAC) >0
				Begin 
					
					Update TblBilling
					Set MAC=@pval,IMEI=@sval
					Where IDBilling=@idbillingaux

				End
			--Fin Adicionado***********************************************
							  
			IF @IDPlan IN(553,554,555)  -- RECARGA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
			BEGIN
				SET @Importe = 149
				SET @IDTipoVenta = 2
			END
			
			IF @IDPlan IN(556,557,558)  -- RECARGA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
			BEGIN
				SET @Importe = 129
				SET @IDTipoVenta = 2
			END
			
			IF @IDPlan IN(553,554,555,556,557,558)		-- RECARGA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
			BEGIN			
				INSERT INTO TblBilling
									  (IDOLOPV, IDOLOUsuario,IDCliente, FechaVenta, IDTipoDispositivo,
									  DesTipoDispositivo, MAC, IDPlan, IDTipoVenta, Importe, IDStatusBilling)
				VALUES     
				(rtrim(ltrim(@IDOLOPV)), RTRIM(LTRIM(@IDOLOUsuario)),@IDCliente, @FechaVenta, 
									  @auxIDTipoDispositivo, 
									  RTRIM(LTRIM(@DesTipoDispositivo)),RTRIM(LTRIM(@MAC)), @IDPlan, @IDTipoVenta, @Importe, 1)

				--Adicionado**************************************************************
				Set @idbillingaux=scope_identity()

				If charindex('|',@MAC) >0
					Begin 
					
						Update TblBilling
						Set MAC=@pval,IMEI=@sval
						Where IDBilling=@idbillingaux

					End
				--Fin Adicionado**********************************************************
			END
											  
		END
    END
else
	BEGIN
		if @IDTipoVenta = 3 --SI ES UNA DEVOLUCIÓN SÓLO ACTUALIZAMOS EL TIPO DE VENTA.
			UPDATE TblBilling SET IDTipoVenta = @IDTipoVenta
			WHERE IDBilling = @IDBilling
		else
		BEGIN
			IF @IDPlan IN(553,554,555)  -- VENTA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
				SET @Importe = 50
			
			IF @IDPlan IN(556,557,558)  -- VENTA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
				SET @Importe = 0
				
			UPDATE TblBilling SET IDOLOPV =  RTRIM(LTRIM(@IDOLOPV)), IDOLOUsuario = RTRIM(LTRIM(@IDOLOUsuario)), FechaVenta = @FechaVenta,  IDTipoDispositivo = @auxIDTipoDispositivo,
			DesTipoDispositivo = RTRIM(LTRIM(@DesTipoDispositivo)), MAC = RTRIM(LTRIM(@MAC)), IDPlan = @IDPlan, IDTipoVenta = @IDTipoVenta,
			Importe = @Importe WHERE IDBilling = @IDBilling

			--Adicionado**************************************************************
				If charindex('|',@MAC) >0
					Begin 
					
						Update TblBilling
						Set MAC=@pval,IMEI=@sval
						Where IDBilling=@IDBilling

					End
				--Fin Adicionado**********************************************************
			
			IF @IDPlan IN(553,554,555)  -- RECARGA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
			BEGIN
				SET @Importe = 149
				SET @IDTipoVenta = 2
			END
			
			IF @IDPlan IN(556,557,558)  -- RECARGA. Promoción Combinada, se registra Venta + Recarga con distinto importe. 8/10/2014
			BEGIN
				SET @Importe = 129
				SET @IDTipoVenta = 2
			END
			
			IF @IDPlan IN(553,554,555,556,557,558)
			BEGIN
				set @IDBilling = (SELECT IDBilling FROM TblBilling
					WHERE FechaVenta = @FechaVenta
					AND IDCliente = @IDCliente
					AND IDTipoVenta = @IDTipoVenta)  
					
				UPDATE TblBilling SET IDOLOPV =  RTRIM(LTRIM(@IDOLOPV)), IDOLOUsuario = RTRIM(LTRIM(@IDOLOUsuario)), FechaVenta = @FechaVenta,  IDTipoDispositivo = @auxIDTipoDispositivo,
				DesTipoDispositivo = RTRIM(LTRIM(@DesTipoDispositivo)), MAC = RTRIM(LTRIM(@MAC)), IDPlan = @IDPlan, IDTipoVenta = @IDTipoVenta,
				Importe = @Importe WHERE IDBilling = @IDBilling

				--Adicionado*******************************************************
				If charindex('|',@MAC) >0
				Begin 
					
					Update TblBilling
					Set MAC=@pval,IMEI=@sval
					Where IDBilling=@IDBilling

				End
				--Fin Adicionado****************************************************

			END		
		END
	END

END   

--Actualizamos los Datos de Cliente si la fecha Venta es mayor que la FechaBilling de ClientesBilling
BEGIN
if @NombreCliente is not null
	BEGIN
	declare @auxFechaBilling datetime
	set @auxFechaBilling = (SELECT FechaBilling FROM TblClientesBilling WHERE IDCliente = @IDCliente)
	--Si no existe se crea...
	if @auxFechaBilling is null 
		BEGIN
		INSERT INTO TblClientesBilling (IDCliente, IDTipoDocumento, NumDocumentoCliente, NombreCliente, FNacCliente, IDGeneroCliente, OcupacionCliente, 
                      NacionalidadCliente, DireccionCliente, IDProvincia, IDDistrito, TelefonoCliente, Celular1Cliente, Celular2Cliente, eMailCliente,
                      FechaBilling)
                      VALUES(@IDCliente, @IDTipoDocumento, 
					  RTRIM(LTRIM(@NumDocumentoCliente)), RTRIM(LTRIM(@NombreCliente)), @FNacCliente, @IDGeneroCliente, RTRIM(LTRIM(@OcupacionCliente)), 
                      RTRIM(LTRIM(@NacionalidadCliente)), RTRIM(LTRIM(@DireccionCliente)), @IDProvincia, 
                      @IDDistritoCliente, RTRIM(LTRIM(@TelefonoCliente)), RTRIM(LTRIM(@Celular1Cliente)), RTRIM(LTRIM(@Celular2Cliente)), RTRIM(LTRIM(@eMailCliente)), @FechaVenta)
		END
		else
			BEGIN
					if @auxFechaBilling < @FechaVenta and @IDTipoVenta = 1					
					UPDATE TblClientesBilling SET
					IDTipoDocumento = @IDTipoDocumento,
					NumDocumentoCliente = RTRIM(LTRIM(@NumDocumentoCliente)), NombreCliente = RTRIM(LTRIM(@NombreCliente)), FNacCliente = @FNacCliente,
					 @IDGeneroCliente = @IDGeneroCliente, OcupacionCliente = RTRIM(LTRIM(@OcupacionCliente)),
					NacionalidadCliente = RTRIM(LTRIM(@NacionalidadCliente)), DireccionCliente = RTRIM(LTRIM(@DireccionCliente)), IDProvincia = @IDProvincia,
					IDDistrito = @IDDistritoCliente, TelefonoCliente = RTRIM(LTRIM(@TelefonoCliente)), Celular1Cliente = RTRIM(LTRIM(@Celular1Cliente)),
					Celular2Cliente = RTRIM(LTRIM(@Celular2Cliente)), eMailCliente = RTRIM(LTRIM(@eMailCliente))
					WHERE IDCliente = @IDCliente
							
			END                      
	END
END
    
END
