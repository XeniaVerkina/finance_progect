﻿
&НаКлиенте
Процедура Рассчитать(Команда)
	СуммаКред = Объект.СуммаКредита ;
	Ств = Объект.ПроцентнаяСтавка;
	Срок = Объект.СрокКредита;

	Если СуммаКред = 0 Или Ств = 0 Или Срок = 0 Тогда
		Сообщить ("Не правильно введены данные!");
		Возврат
	Иначе
		Колмес = Срок*12;
		Годсумм = (Суммакред/Срок/100*Ств) + (СуммаКред/Срок);
		Переплата = Годсумм*Срок - Суммакред;
		ОбщСумма = СуммаКред + Переплата;
		ЕжемПлат = Общсумма / КолМес;  

		Для Счетчик = 1 По КолМес Цикл
			НоваяСтрока = Объект.Результат.Добавить();
			НоваяСтрока.Месяц = Счетчик;
			НоваяСтрока.СуммаПлатежа = ЕжемПлат;
			ОбщСумма = ОбщСумма - ЕжемПлат; 
			НоваяСтрока.ОстатокЗадолженности = ОбщСумма;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры


	