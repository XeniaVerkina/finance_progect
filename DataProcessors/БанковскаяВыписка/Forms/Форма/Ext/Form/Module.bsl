﻿
&НаКлиенте
Процедура ВыпискаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Проводник = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие) ;
	Проводник.Заголовок = "Выберите банковскую выписку";
	Фильтр = "ТекстовыйДокумент (*.csv)|*.csv";        
	Проводник.Фильтр = Фильтр ;
	Оповещение = Новый ОписаниеОповещения("ПослеВыбораФайла", ЭтотОбъект) ;
	Проводник.Показать(Оповещение) ; 
	
КонецПроцедуры 

&НаКлиенте
Процедура ПослеВыбораФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат ;
	КонецЕсли ;
	
	Объект.Выписка = ВыбранныеФайлы[0] ;

КонецПроцедуры 

&НаСервере
Процедура ПрочитатьФайлНаСервере(АдресДанных)
	Объект.ДанныеФайла.Очистить();
	ПоследовательноеЧтение = Истина ;
	Если ПоследовательноеЧтение Тогда
		Текст = Новый ЧтениеТекста ;
		Данные = ПолучитьИзВременногоХранилища(АдресДанных) ;
		ВыпискаНаСервере = ПолучитьИмяВременногоФайла("csv") ;
		Данные.Записать(ВыпискаНаСервере);
		
		Текст.Открыть(ВыпискаНаСервере) ;  
		ТекСтрока = Текст.ПрочитатьСтроку() ;
		ТекСтрока = Текст.ПрочитатьСтроку() ;
		Пока ТекСтрока <> Неопределено Цикл
			МассивСлов = СтрРазделить(ТекСтрока, ";") ;
			НоваяСтрока = Объект.ДанныеФайла.Добавить() ;
			НоваяСтрока.ТипКарты = МассивСлов[0] ;
			НоваяСтрока.НомерКарты = МассивСлов[1] ;
			НоваяСтрока.ДатаСовершенияОперации =  Дата(Прав(МассивСлов[2],4)+Сред(МассивСлов[2],4,2)+Лев(МассивСлов[2],2)+"000000");
			НоваяСтрока.ДатаОбработкиОперации = Дата(Прав(МассивСлов[3],4)+Сред(МассивСлов[3],4,2)+Лев(МассивСлов[3],2)+"000000");
			НоваяСтрока.КодАвторизации = МассивСлов[4] ;
			НоваяСтрока.ТипОперации = МассивСлов[5] ;
			НоваяСтрока.ГородСовершения = МассивСлов[6] ;
			НоваяСтрока.СтранаСовершения = МассивСлов[7] ;
			НоваяСтрока.Описание = МассивСлов[8] ;
			НоваяСтрока.ВалютаОперации = МассивСлов[9] ;
			НоваяСтрока.СуммаВВалютеОперации = МассивСлов[10] ;
			НоваяСтрока.СуммаВВалютеСчета = МассивСлов[11] ;
			ТекСтрока = Текст.ПрочитатьСтроку() ;	
		КонецЦикла ;
	КонецЕсли ;
КонецПроцедуры         

&НаКлиенте
Процедура ПрочитатьФайл(Команда) 
	ДанныеФайла = Новый ДвоичныеДанные(Объект.Выписка) ;
	АдресДанных = ПоместитьВоВременноеХранилище(ДанныеФайла) ;
	ПрочитатьФайлНаСервере(АдресДанных);
КонецПроцедуры  

&НаКлиенте
Процедура ЗаписатьДанные(Команда)
	ЗаписатьДанныеНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДанныеНаСервере()
	МассивКод = Новый Массив;
	Для каждого СтрокаДанных Из Объект.Данныефайла Цикл
		МассивКод.Добавить(СтрокаДанных.КодАвторизации);
	КонецЦикла ; 
	 	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВыпискиИзБанков.Ссылка КАК Ссылка,
		|	ВыпискиИзБанков.КодАвторизации КАК КодАвторизации
		|ИЗ
		|	Документ.ВыпискиИзБанков КАК ВыпискиИзБанков
		|ГДЕ
		|	ВыпискиИзБанков.КодАвторизации В(&МассивКод)";
		
	Запрос.УстановитьПараметр ("МассивКод", МассивКод) ;
	РезультатЗапроса = Запрос.Выполнить() ;
	ТаблицаВыписки = РезультатЗапроса.Выгрузить() ;
	Для каждого СтрокаДанных Из Объект.ДанныеФайла Цикл
		НайденныйКод = ТаблицаВыписки.Найти(СтрокаДанных.КодАвторизации, "КодАвторизации");
		Если НайденныйКод <> Неопределено Тогда
			Продолжить;
		КонецЕсли ;   
		НоваяВыписка = Документы.ВыпискиИзБанков.СоздатьДокумент();
		НоваяВыписка.НомерКарты = СтрокаДанных.НомерКарты;
		НоваяВыписка.Дата = СтрокаДанных.ДатаСовершенияОперации;
		НоваяВыписка.КодАвторизации = СтрокаДанных.КодАвторизации;
		НоваяВыписка.ГородСовершения = СтрокаДанных.ГородСовершения;  
		НоваяВыписка.Описание = СтрокаДанных.Описание;
		НоваяВыписка.СуммаВВалютеСчета = СтрокаДанных.СуммаВВалютеСчета ;
		НоваяВыписка.Записать() ;
	КонецЦикла;
	Сообщить("Операции записаны") ;
		
КонецПроцедуры


