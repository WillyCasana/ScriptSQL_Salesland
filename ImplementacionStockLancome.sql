use [LANCOME-PE]
go

--use [larocheposay-pe]
--go

--use [maybelline-pe]
--go

Declare @fini datetime,@ffin datetime
Set @ffin  = cast(getdate() as date)  
Set @fini = cast( dateadd(month,-1,getdate()) as date) 

Declare @cadsede nvarchar(max)
Set @cadsede=Cast((select Cia,Sede from dbo.SedeImportacion 
Where Id_Estado='01'
for xml raw('d'),root('r')) As nvarchar(max))

select @cadsede
/*
exec   LSKO.SalesDat.dbo.usp_ConsolidarArticuloStock @fini, @ffin,@cadsede
exec   dbo.usp_ActualizarArticuloStock @fini, @ffin

exec  LSKO.SalesDat.dbo.usp_ConsolidarVentas @fini, @ffin,@cadsede
exec usp_ActualizarVentaArticulo @fini, @ffin

exec LSKO.SalesDat.dbo.usp_ConsolidarVentasClasificacion @fini, @ffin,@cadsede
exec usp_ActualizarVentaArticuloClasificacion @fini, @ffin


select * from [dbo].[ArticuloStock]


sp_helptext "[usp_ConsolidaryActualizarArticuloStock]"

sp_helptext "[usp_ConsolidaryActualizarVentaArticulo]"


exec   LSKO.SalesDat.dbo.usp_ConsolidarArticuloStock @fini,@ffin,@cadsede
exec  LSKO.SalesDat.dbo.usp_ConsolidarVentas @fini,@ffin,@cadsede

[dbo].[usp_ConsolidarArticuloStock]

*/


--exec   LSKO.SalesDat.dbo.usp_ConsolidarArticuloStockLancome @fini, @ffin,@cadsede
--exec   dbo.usp_ActualizarArticuloStock @fini, @ffin


select * from articulostock

exec [dbo].[usp_ConsolidaryActualizarArticuloStock] '20160101','20161231'

ALTER PROCEDURE [dbo].[usp_ConsolidaryActualizarArticuloStock]
@fini datetime
,@ffin datetime
As
--------------------------------------------------------------------------------
-->Objetivo : SP para consolidar y obtener la data del reporte procente del Kontroller
--------------------------------------------------------------------------------
-->Fecha : 29/04/15
-->Autor : Willy Casana
--------------------------------------------------------------------------------
-->Fecha : 15/09/15
-->Autor : Willy Casana
-->Comentario: parametrización de sede
--------------------------------------------------------------------------------
Set NoCount On

Declare @cadsede nvarchar(250)
Set @cadsede=Cast(
					(
					select Cia,Sede 
					from dbo.SedeImportacion
					Where id_estado ='01'
					for xml raw('d'),root('r') 

					)
					As nvarchar(250)
				)

exec   LSKO.SalesDat.dbo.usp_ConsolidarArticuloStockLancome @fini,@ffin,@cadsede
exec   dbo.usp_ActualizarArticuloStock @fini,@ffin
go