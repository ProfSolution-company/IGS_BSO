﻿
// <ИГС> ПР Потылицын Г.С. #0011 {

#Область ПрограммныйИнтерфейс

Функция СведенияОВнешнейОбработке() Экспорт
	
	// Заполнение ПараметровРегистрации
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Наименование = "Сформировать документы ""Реализация строительных работ, услуг""";
	// <ИГС> ПР Потылицын Г.С. #0012 {
	ПараметрыРегистрации.Версия = "1.1";
	ПараметрыРегистрации.Информация = "Обработка позволяет формировать или обновлять документы
	|""Реализация строительных работ, услуг"", заполненных на основании Скважин.
	|
	|Нововведения версии 1.1 от 08.07.2025:
	| - Создается/Изменяется ""Расчет выполнения проектов"" при нажатии ""Сформировать документы"";
	| - Организация заполняется по умолчанию при открытии формы.
	|
	// } </ИГС>
	|Автор: <ИГС> ПР Потылицын Г.С. #0011, 23.04.2025";
	
	// Добавление команды 
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = "Открыть форму";
	НоваяКоманда.Идентификатор = НоваяКоманда.Представление;
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Создает/Изменяет документ Реализации по указанному * Проекту, метод взаимодействия 
// определяется по отсутствию/наличию * ДокументаРеализации
Функция СоздатьДокументыРСРиУ(Проект, ДокументРеализации = Неопределено) Экспорт
	
	// Скважина и ее основные данные
	Скважина = ТаблицаПроектов.НайтиСтроки(Новый Структура("Проект", Проект))[0];
	
	// Массив элементов Скважины
	МассивНГ = ТаблицаПроектовДетальная.НайтиСтроки(Новый Структура("Проект", Проект));
	
	// Получение предопеделенной номенклатуры, определение её НДС
	НоменклатураУслуг		= ПредопределенноеЗначение("ПланВидовХарактеристик.игсНастройкиМеханизмов.НоменклатураУслугДляРеализацииСтроительныхРабот");
	НоменклатураЗначение	= игсНастройкиМеханизмовВызовСервера.ПолучитьЗначениеНастройки(НоменклатураУслуг, Организация);
	НоменклатураНДС			= ПреобразованиеПеречисленияНДС(НоменклатураЗначение.ВидСтавкиНДС, Дата);
	НоменклатураНДСКоэф		= УчетНДСПереопределяемый.ПолучитьСтавкуНДС(НоменклатураНДС);
	
	// Создание/Редактирование и заполнение документа "РЕАЛИЗАЦИЯ СТРОИТЕЛЬНЫХ РАБОТ И УСЛУГ"
	Если ДокументРеализации <> Неопределено Тогда
		НовыйДок = ДокументРеализации.ПолучитьОбъект();
	Иначе
		НовыйДок = Документы.ИмпРеализацияСтроительныхРаботУслуг.СоздатьДокумент(); 
	КонецЕсли;
	
	// Основные реквизиты
	НовыйДок.Дата				= Дата;
	НовыйДок.ВалютаДокумента	= Константы.ВалютаРегламентированногоУчета.Получить();
	НовыйДок.ВидОперации		= Перечисления.ИмпВидыОперацийРеализацияСтроительныхРаботУслуг.ПоэтапнаяПередачаСМР;
	
	// Остальные реквизиты
	НовыйДок.Организация					= Организация;
	НовыйДок.ПодразделениеОрганизации		= Подразделение;
	НовыйДок.ПрименятьОтложенныйНДС			= Ложь;
	НовыйДок.ДокументБезНДС					= ?(НоменклатураНДСКоэф > 0, Ложь, Истина);
	НовыйДок.игсПроект						= Проект;
	НовыйДок.Контрагент						= Проект.игсЗаказчик;
	НовыйДок.ДоговорКонтрагента				= Проект.игсДоговор;
	НовыйДок.СчетУчетаРасчетовСКонтрагентом	= ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.РасчетыСПокупателями");
	НовыйДок.СчетУчетаРасчетовПоАвансам		= ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.РасчетыПоАвансамПолученным");
	НовыйДок.СпособЗачетаАвансов			= Перечисления.СпособыЗачетаАвансов.Автоматически; 
	
	НовыйДок.Услуги.Очистить();
	
	Для Каждого НГСтрока из МассивНГ Цикл
		
		Стр = НовыйДок.Услуги.Добавить(); 
		
		// Основные реквизиты
		Стр.Номенклатура	= НоменклатураЗначение;
		Стр.Количество		= 1; 
		Стр.Субконто		= НГСтрока.НоменклатурнаяГруппа;
		
		// Реквизиты-счета
		Стр.СчетДоходов					= ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.ВыручкаНеЕНВД");
		Стр.СчетРасходов				= ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.СебестоимостьПродажНеЕНВД");
		Стр.СчетУчетаНДСПоРеализации	= ПредопределенноеЗначение("ПланСчетов.Хозрасчетный.Продажи_НДС");
		
		// Формулируемые реквизиты
		НакопительныеЗатраты = Скважина.НачальныйОстатокЗатрат + НГСтрока.ФактическиеЗатратыДетально; 
		Стр.Цена = (Скважина.ПлановаяВыручка * НакопительныеЗатраты / Скважина.ПлановыеЗатраты) 
		- (НГСтрока.ФактическаяВыручкаДетально + Скважина.НачальныйОстатокВыручки); 
		
		Стр.Сумма = Стр.Цена * Стр.Количество;
		
		// Реквизиты с НДС
		Стр.СтавкаНДС = НоменклатураНДС;
		Стр.СуммаНДС = Стр.Сумма * (НоменклатураНДСКоэф / 100);
		
	КонецЦикла;
	
	НовыйДок.Записать(РежимЗаписиДокумента.Запись);
	
	Возврат НовыйДок;
	
КонецФункции

// <ИГС> ПР Потылицын Г.С. #0012 {

// Создает/Изменяет документ Расчетов по указанному * МассивуПроектов, метод взаимодействия 
// определяется по отсутствию/наличию * ЭтоНовыйДокумент,
// Объект * ДокументРасчета изменяется
Функция СоздатьДокументыРВП(МассивПроектов, ДокументРасчета, ЭтоНовыйДокумент) Экспорт 
	
	// Определение объекта на изменение
	Если ЭтоНовыйДокумент Тогда
		НовыйДок = Документы.игсРасчетВыполненияПроектов.СоздатьДокумент();
	Иначе
		НовыйДок = ДокументРасчета.ПолучитьОбъект();
		НовыйДок.Проекты.Очистить();
	КонецЕсли;
	
	// Заполнение основных реквизитов
	НовыйДок.Организация	= Организация;
	НовыйДок.Дата			= Дата;
	НовыйДок.Ответственный	= Пользователи.ТекущийПользователь(); 
	
	// Заполнение ТЧ "Проекты"
	Для Каждого Проект Из МассивПроектов Цикл
		
		ТекСтр = ТаблицаПроектов[Проект];
		
		СуммаДокумента = ТекСтр.ДокументРеализации.Услуги.Итог("Сумма");
		
		Стр = НовыйДок.Проекты.Добавить();
		Стр.Проект					= ТекСтр.Проект;
		Стр.ЗатратыПроектаФакт		= ТекСтр.ФактическиеЗатраты + ТекСтр.НачальныйОстатокЗатрат;
		Стр.ВыручкаПроектаФакт		= ТекСтр.ФактическаяВыручка + ТекСтр.НачальныйОстатокВыручки + СуммаДокумента; 
		Стр.ЗатратыПроектаПлан		= ТекСтр.ПлановыеЗатраты; 
		Стр.ВыручкаПроектаПлан		= ТекСтр.ПлановаяВыручка;
		Стр.ПроцентЗавершенности	= Стр.ЗатратыПроектаФакт / Стр.ЗатратыПроектаПлан * 100;
		
		// АКТУАЛЬНЫЕ ФОРМУЛЫ РАСЧЕТА
		// o ЗатратыПроектаФакт = ФактЗатраты + НачальныеОстаткиЗатрат
		// o ВыручкаПроектаФакт = ФактВыручка + НачальныеОстаткиВыручки + СуммаДокументРеализации
		
		// o ЗатратыПроектаПлан = ПлановоеЗначениеИзРегистра
		// o ВыручкаПроектаПлан = ПлановоеЗначениеИзРегистра
		
		// o ПроцентЗавершенности = ЗатратыПроектаФакт / ПлановоеЗначениеИзРегистраСебестоимость * 100
		
	КонецЦикла;
	
	// Может возникнуть ситуация, когда комбинация измерений (организация + проект) является
	// не уникальной для этого месяца; В таком случае, документ не проводится, но записывается
	Попытка
		НовыйДок.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
		НовыйДок.Записать(РежимЗаписиДокумента.Запись);
	КонецПопытки;
	
	Возврат НовыйДок;	
	
КонецФункции
// } </ИГС>

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Конвертор позволяет преобразовывать перечисления: ВидСтавкиНДС => СтавкиНДС
Функция ПреобразованиеПеречисленияНДС(ВидСтавкиНДС, Дата)
	
	// Общий НДС 20%			(после 01.01.2019)
	Если 		ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.Общая И Дата > Дата("20190101") Тогда
		Возврат Перечисления.СтавкиНДС.НДС20;
		
	// Общий расчетный НДС 20%	(после 01.01.2019)
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.ОбщаяРасчетная И Дата > Дата("20190101") Тогда
		Возврат Перечисления.СтавкиНДС.НДС20_120;
		
	// Общий НДС 18%			(до 01.01.2019)
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.Общая И Дата < Дата("20190101") Тогда
		Возврат Перечисления.СтавкиНДС.НДС18;
		
	// Общий расчетный НДС 18%	(до 01.01.2019)	
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.ОбщаяРасчетная И Дата < Дата("20190101") Тогда
		Возврат Перечисления.СтавкиНДС.НДС18_118;
		
	// Пониженный НДС 10%
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.Пониженная Тогда  
		Возврат Перечисления.СтавкиНДС.НДС10;
		
	// Пониженный расчетный НДС 10%
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.ПониженнаяРасчетная Тогда 
		Возврат Перечисления.СтавкиНДС.НДС10_110;
		
	// НДС 0%
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.Нулевая Тогда
		Возврат Перечисления.СтавкиНДС.НДС0;
		
	// Без НДС
	ИначеЕсли 	ВидСтавкиНДС = Перечисления.ВидыСтавокНДС.БезНДС Тогда
		Возврат Перечисления.СтавкиНДС.БезНДС; 	
		
	КонецЕсли;
	
	Возврат Перечисления.СтавкиНДС.БезНДС;
	
КонецФункции

#КонецОбласти

// } </ИГС>