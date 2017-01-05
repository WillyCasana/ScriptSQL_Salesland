Declare @cadsede nvarchar(max) 
Set @cadsede=N'<r><d Cia="02" Sede="47"/><d Cia="02" Sede="51"/></r>'


Declare @tsede table(Cia char(2),Sede char(2))
Declare @idoc int

exec sp_xml_preparedocument @idoc output,@cadsede

Insert Into @tsede(Cia,Sede)
Select Cia,Sede 
From OpenXML(@idoc,'r/d',1)
With (Cia char(2),Sede char(2))

select * from @tsede

Select  
			 c.CIA
			,c.DESCRIPCION as Compania
			,s.SEDE as ID_Sede
			,s.DESCRIPCION as Sede
			,al.ID_ALMACEN
			,al.DESCRIPCION as Almacen
			,a.ID_ARTICULO
			,a.DESCRIPCION as Articulo
			,a.ID_ESTADO
			--,RPVP.Pvp as PrecioVentaP
			,a.CU_01 as ValorCompra
			,a.FE as Articulo_FE
			,a.FC as Articulo_FC
			,StockCIA = a.STOCK
			--,StockSe= isnull( res.CANT_DISPONIBLE,0)
			--,StockAl =isnull(  ral.CANT_DISPONIBLE,0)
			,a.Nro_Parte
			,a.Descripcion_Larga
			,a.Modelo
			--Cantidad=count(1)
			From dbo.Compania  c 
			Inner Join dbo.Sede s on (c.CIA = s.CIA)
			Inner Join dbo.Almacen al on (s.Sede = al.Sede)
			Inner Join dbo.ARTICULO a
				on ( c.Cia  = a.CIA and a.SE=s.Sede)
			Inner Join EXISTENCIA_ALMACEN ea
				On (a.Id_Articulo = ea.ID_ARTICULO  )
			--Outer Apply (Select es.CANT_DISPONIBLE 
			--				From dbo.EXISTENCIA_SEDE es(NoLock)
			--				Where es.CIA = c.CIA
			--					and es.sede=s.SEDE 
			--					and es.id_articulo=a.id_articulo
			--					and es.id_estado='01'
			--					and es.cant_disponible<>0
			--							) res
			--outer Apply (Select ea.CANT_DISPONIBLE 
			--				From dbo.EXISTENCIA_ALMACEN ea(NoLock) 
			--				Where ea.CIA = c.CIA
			--					and ea.sede=s.SEDE 
			--					and ea.ID_ALMACEN = al.ID_ALMACEN
			--					and ea.id_articulo=a.id_articulo
			--					and ea.id_estado='01'
			--					and ea.cant_disponible<>0
			--							) ral
			--Outer Apply(Select  avg(isnull(dv.precio,0)) as Pvp
			--				from dbo.DOCUMENTO_CC_DETALLE dv(NoLock)
			--				Where dv.ID_ARTICULO = a.ID_ARTICULO
			--						and dv.ID_ESTADO ='01'   ) as RPVP

			Where c.CIA = '02' --Salesland
				and a.Id_Clasifica1 ='004' --para Loreal
				--and Exists(Select 1 
				--	From @tsede --dbo.sedeimportacion
				--	Where Cia=s.Cia
				--			and Sede=s.SEDE
				--)
				--and (a.FC Between '20150101' and '20161231' )
				and a.ID_Articulo='LANTRALIM0000001'
go

--(197299 row(s) affected)


Declare @cadsede nvarchar(max) 
Set @cadsede=N'<r><d Cia="02" Sede="47"/><d Cia="02" Sede="51"/></r>'


Declare @tsede table(Cia char(2),Sede char(2))
Declare @idoc int

exec sp_xml_preparedocument @idoc output,@cadsede

Insert Into @tsede(Cia,Sede)
Select Cia,Sede 
From OpenXML(@idoc,'r/d',1)
With (Cia char(2),Sede char(2))


select 
		c.CIA
		,c.DESCRIPCION as Compania
		,s.SEDE as ID_Sede
		,s.DESCRIPCION as Sede
		,al.ID_ALMACEN
		,al.DESCRIPCION as Almacen
		,a.ID_ARTICULO
		,a.DESCRIPCION as Articulo
		,a.ID_ESTADO
		,RPVP.Pvp as PrecioVentaP
		,a.CU_01 as ValorCompra
		,a.FE as Articulo_FE
		,a.FC as Articulo_FC
		,StockCIA = a.STOCK
		,StockSe= isnull( res.CANT_DISPONIBLE,0)
		,StockAl =isnull(  ea.CANT_DISPONIBLE,0)
		,a.Nro_Parte
		,a.Descripcion_Larga
		,a.Modelo
From EXISTENCIA_ALMACEN ea
Inner Join dbo.Articulo a
	On (ea.ID_ARTICULO = a.ID_ARTICULO and ea.CIA = a.CIA)
Inner Join dbo.Almacen al on (ea.ID_ALMACEN = al.Id_Almacen 
		and ea.CIA= al.CIA and ea.SEDE = al.SEDE)
Inner Join dbo.sede s on (ea.sede=s.sede and ea.CIA = s.CIA)
Inner Join dbo.Compania c on (ea.Cia= c.CIA)
Outer Apply (Select es.CANT_DISPONIBLE 
	From dbo.EXISTENCIA_SEDE es(NoLock)
	Where es.CIA = c.CIA
		and es.sede=s.SEDE 
		and es.id_articulo=a.id_articulo
		and es.id_estado='01'
		and es.cant_disponible<>0
				) res
Outer Apply(Select  avg(isnull(dv.precio,0)) as Pvp
						from dbo.DOCUMENTO_CC_DETALLE dv(NoLock)
						Where dv.ID_ARTICULO = a.ID_ARTICULO
								and dv.ID_ESTADO ='01'   ) as RPVP
Where 
	ea.CIA='02'
	and ea.CANT_DISPONIBLE<>0
	and Exists(Select 1 
					From @tsede ts --dbo.sedeimportacion
					Where ts.Cia=s.Cia
							and ts.Sede=s.SEDE
				)
				and (a.FC Between '20150101' and '20161231' )
go

ALTER PROCEDURE [dbo].[usp_ConsolidarArticuloStockLancome]
@fecini datetime
,@fecfin datetime
,@cadsede nvarchar(max) --add
As
-----------------------------------------------------------
-->Objetivo : Consolida la consulta de la informacion de Kontroller y asi facilitar el
-->					jale de información via linked server
-----------------------------------------------------------
-->Autor : Willy Casana
-->Creación :  06/04/2015
-----------------------------------------------------------
-->Modificacion1 : 08/05/2015
-->Autor: Willy Casana
-->Comentario : Se adicionó el campo Nro_Parte
-----------------------------------------------------------
-->Modificacion2 : 21/05/2015
-->Autor: Willy Casana
-->Comentario : Se adicionó el campo Descripcion_Larga,Modelo
-----------------------------------------------------------
-->Modificacion2 : 15/09/2015
-->Autor: Willy Casana
-->Comentario : Se adicionó el parámetro @cadsede y truncate table ArticuloStock
-----------------------------------------------------------

SET NOCOUNT ON;


Declare @tsede table(Cia char(2),Sede char(2))
Declare @idoc int

exec sp_xml_preparedocument @idoc output,@cadsede

Insert Into @tsede(Cia,Sede)
Select Cia,Sede 
From OpenXML(@idoc,'r/d',1)
With (Cia char(2),Sede char(2))

Truncate Table dbo.ArticuloStock  --add

;Merge dbo.ArticuloStock as Target
Using(	
select 
		c.CIA
		,c.DESCRIPCION as Compania
		,s.SEDE as ID_Sede
		,s.DESCRIPCION as Sede
		,al.ID_ALMACEN
		,al.DESCRIPCION as Almacen
		,a.ID_ARTICULO
		,a.DESCRIPCION as Articulo
		,a.ID_ESTADO
		,RPVP.Pvp as PrecioVentaP
		,a.CU_01 as ValorCompra
		,a.FE as Articulo_FE
		,a.FC as Articulo_FC
		,StockCIA = a.STOCK
		,StockSe= isnull( res.CANT_DISPONIBLE,0)
		,StockAl =isnull(  ea.CANT_DISPONIBLE,0)
		,a.Nro_Parte
		,a.Descripcion_Larga
		,a.Modelo
From EXISTENCIA_ALMACEN ea
Inner Join dbo.Articulo a
	On (ea.ID_ARTICULO = a.ID_ARTICULO and ea.CIA = a.CIA)
Inner Join dbo.Almacen al on (ea.ID_ALMACEN = al.Id_Almacen 
		and ea.CIA= al.CIA and ea.SEDE = al.SEDE)
Inner Join dbo.sede s on (ea.sede=s.sede and ea.CIA = s.CIA)
Inner Join dbo.Compania c on (ea.Cia= c.CIA)
Outer Apply (Select es.CANT_DISPONIBLE 
	From dbo.EXISTENCIA_SEDE es(NoLock)
	Where es.CIA = c.CIA
		and es.sede=s.SEDE 
		and es.id_articulo=a.id_articulo
		and es.id_estado='01'
		and es.cant_disponible<>0
				) res
Outer Apply(Select  avg(isnull(dv.precio,0)) as Pvp
						from dbo.DOCUMENTO_CC_DETALLE dv(NoLock)
						Where dv.ID_ARTICULO = a.ID_ARTICULO
								and dv.ID_ESTADO ='01'   ) as RPVP
Where 
	ea.CIA='02'
	and ea.CANT_DISPONIBLE<>0
	and Exists(Select 1 
					From @tsede ts --dbo.sedeimportacion
					Where ts.Cia=s.Cia
							and ts.Sede=s.SEDE
				)
				and (a.FC Between @fecini and @fecfin )
				
) as source on (Target.ID_Sede = Source.Id_Sede
				and Target.Id_Almacen = Source.Id_Almacen
				and Target.Id_Articulo = Source.Id_Articulo)
When Matched Then
	Update Set 
			 Id_Estado = source.Id_Estado
			 ,PrecioVentaP = source.PrecioVentaP
			 ,ValorCompra = source.ValorCompra
			 ,Articulo_FE= source.Articulo_FE
			 ,Articulo_FC = source.Articulo_FC
			 ,StockCIA=  source.StockCIA
			 ,StockSe = source.StockSe
			 ,StockAl =  source.StockAl
			 ,Nro_Parte = Source.Nro_Parte
			 ,Descripcion_Larga = Source.Descripcion_Larga
			 ,Modelo = Source.Modelo
When Not Matched Then
			Insert (CIA,Compania,Id_Sede,Sede,Id_Almacen,Almacen,Id_Articulo
					,Articulo,Id_Estado,PrecioVentaP,Articulo_FE
					,Articulo_Fc,StockCIA,StockSe,StockAl,Nro_Parte,Descripcion_Larga,Modelo)
			Values(Source.CIA,Source.Compania,Source.Id_Sede,Source.Sede,Source.Id_Almacen
			,Source.Almacen,Source.Id_Articulo
					,Source.Articulo,Source.Id_Estado,Source.PrecioVentaP,Source.Articulo_FE
					,Source.Articulo_Fc,Source.StockCIA,Source.StockSe,Source.StockAl,Source.Nro_Parte
					,Source.Descripcion_Larga
					,Source.Modelo
					);
go
