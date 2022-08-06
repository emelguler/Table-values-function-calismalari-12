

use Okul

--Ogretmenlerin Ilgili Donemdeki Derse Gore Basari Harf Notunu veren fonksiyon:


create FUNCTION FN$OgretmenlerinIlgiliDonemdekiDerseGoreBasariHarfNotu
(

  @Donem_Id int,
  @Ogretmen_Id int ,
  @Ders_Id int
)
    RETURNS @table TABLE (
       AdiSoyadi nvarchar(64),
	   DersAdi nvarchar(16),
	   DersiAlanOgrenciSayisi int,
	   BasariNotuOrtalamasi tinyint,
	   BasariHarfNotu Char(2)
    )
AS
BEGIN
   declare  @AdiSoyadi nvarchar(64),
	        @DersAdi nvarchar(16),
	        @DersiAlanOgrenciSayisi int,
	        @BasariNotuOrtalamasi tinyint,
	        @BasariHarfNotu Char(2)
 
 select @AdiSoyadi = Adi+' '+SoyAdi from dbo.Ogretmen 
 where Id = @Ogretmen_Id and Statu = 1

 select @DersAdi= Adi from dbo.Ders
 where Id=@ders_Id

 (select @DersiAlanOgrenciSayisi= count(*)    from

(select o.Id as Ogretmen_Id, og.Id as Ogrenci_Id,(o.Adi+o.SoyAdi) as adsoyad, d.Id as Ders_Id, do.Id as Dönem_Id  from dbo.OgrenciOgretmenDers as ood
inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
inner join dbo.Ogrenci as og on og.Id=ood.Ogrenci_Id and og.statu=1
where 
od.Donem_Id=1
and 
ood.Statu=1
and d.Id=@Ders_Id
and do.Id=@Donem_Id
and o.Id=@Ogretmen_Id
group by o.Id,d.Id,do.Id,og.Id,o.Adi+o.SoyAdi)c

group by c.Ogretmen_Id, c.adsoyad,c.Dönem_Id 
)


select  @BasariNotuOrtalamasi=((dbo.FN$OgretmeneAitHerbirDersinOrtalamaToplamlari(@Ogretmen_Id , @Ders_Id , @Donem_Id )) /(dbo.FN$OgretmeninVerdigiDerseGoreOgrenciSayisi(@Ogretmen_Id ,@Ders_Id ,@Donem_Id)))

select  @BasariHarfNotu=[dbo].FN$OgretmenBasariHarfNotu(@Ogretmen_Id,@Ders_Id,@Donem_Id  )

 INSERT INTO @table(AdiSoyadi,DersAdi,DersiAlanOgrenciSayisi,  BasariNotuOrtalamasi,BasariHarfNotu)
       

	   
	    SELECT 				 
		    @AdiSoyadi,
			@DersAdi,
			@DersiAlanOgrenciSayisi,
			@BasariNotuOrtalamasi,
			@BasariHarfNotu
    RETURN;
END;









--Çaðýralým:
select * from dbo.FN$OgretmenlerinIlgiliDonemdekiDerseGoreBasariHarfNotu(1,5,8)













--where clause kontrolü:

 select  a.*,[dbo].FN$OgretmenBasariHarfNotu(a.Ogretmen_Id,a.Ders_Id,a.Donem_Id ) as BasariHarfNotu    
 from(select  count(*) as dersialanogrencisayisi  ,od.Ogretmen_Id,o.Adi+ +o.SoyAdi as adisoyadi,od.Ders_Id,
 d.Adi,do.Id as Donem_Id
 from dbo.OgrenciOgretmenDers as ood
inner join dbo.OgretmenDers
as od  on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ogretmen as o on o.Id=od.Ogretmen_Id and o.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
where ood.Statu=1
and od.Ogretmen_Id=5
and od.Ders_Id=8
group by od.Ogretmen_Id,d.Adi,od.Ders_Id,o.Adi,o.SoyAdi,do.Id)a
