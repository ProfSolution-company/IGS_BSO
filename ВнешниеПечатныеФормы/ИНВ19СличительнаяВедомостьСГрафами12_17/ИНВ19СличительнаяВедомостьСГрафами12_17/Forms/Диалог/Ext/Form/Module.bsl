﻿
&НаСервере
Функция ПечатьНаСервере()
	 ДокументОбъект = РеквизитФормыВЗначение("Объект");
	 МассивПечати = новый Массив;
	 МассивПечати.Добавить(ДокументОбъект.ссылканаОбъект);
	 Если ВремяИнвентаризации = 0 Тогда
		 результат = ДокументОбъект.Печать(МассивПечати,новый ТаблицаЗначений, новый СписокЗначений, новый Структура,ложь);
	 Иначе
		 результат = ДокументОбъект.Печать(МассивПечати,новый ТаблицаЗначений, новый СписокЗначений, новый Структура,Истина);
	 КонецЕсли;
	 возврат Результат;
КонецФункции


&НаКлиенте
Процедура Печать(Команда)
	Результат = ПечатьнаСервере();
	Результат.Показать()
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.СсылкаНаОбъект = Параметры.ОбъектыНазначения[0];
КонецПроцедуры

