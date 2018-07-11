﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Базовая функциональность".
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Регистрация результата работы для вывода на клиенте.

// Формирует структуру для регистрации результата выполнения и последующего вывода.
//
// Возвращаемое значение:
//   Результат - Структура - Результат выполнения операции, который необходимо вывести.
//       * Шаги - СписокЗначений - Шаги сценария.
//           * Представление - Имя шага.
//           * Значение      - Параметры шага.
//
// См. также:
//   СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения().
//
Функция ОписаниеРезультатаВыполнения(Результат = Неопределено) Экспорт
	Если Результат = Неопределено Тогда
		Результат = Новый Структура;
	КонецЕсли;
	Если Не Результат.Свойство("Шаги") Тогда
		Результат.Вставить("Шаги", Новый СписокЗначений);
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Добавляет в структуру информацию о типах, которые необходимо обновить в динамических списках.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   СсылкаИлиТипИлиМассив - Массив - Тип или ссылки измененных объектов,
//       которые требуется обновить в динамических списках.
//   ИсточникОповещенияФорм - Произвольный - Источник широковещательного оповещения открытых форм.
//       Заполняется в случае, если помимо оповещения динамических списков
//       также требуется разослать широковещательное оповещение открытых форм с именем события "Запись_<ИмяОбъектаМетаданных>".
//       Используется только при вызове с сервера.
//
Процедура ОповеститьДинамическиеСписки(Результат, СсылкаИлиТипИлиМассив, ПараметрОповещенияФорм = Неопределено) Экспорт
	Если СсылкаИлиТипИлиМассив = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	// Преобразование оповещения в массив.
	
	МассивТипов = Новый Массив;
	ИспользоватьШироковещательноеОповещение = (ПараметрОповещенияФорм <> Неопределено);
	Если ИспользоватьШироковещательноеОповещение Тогда
		МассивСсылокВРазрезахТипов = Новый Соответствие;
	КонецЕсли;
	ТипСсылкиИлиТипаИлиМассива = ТипЗнч(СсылкаИлиТипИлиМассив);
	Если ТипСсылкиИлиТипаИлиМассива = Тип("Массив") Тогда
		Для Каждого Элемент Из СсылкаИлиТипИлиМассив Цикл
			ТипЭлемента = ТипЗнч(Элемент);
			Если ТипЭлемента = Тип("Тип") Тогда
				ТипЭлемента = Элемент;
			КонецЕсли;
			Если МассивТипов.Найти(ТипЭлемента) = Неопределено Тогда
				МассивТипов.Добавить(ТипЭлемента);
				Если ИспользоватьШироковещательноеОповещение Тогда
					МассивСсылокВРазрезахТипов.Вставить(ТипЭлемента, Новый Массив);
				КонецЕсли;
			КонецЕсли;
			Если ИспользоватьШироковещательноеОповещение И ТипЭлемента <> Тип("Тип") Тогда
				МассивСсылокВРазрезахТипов[ТипЭлемента].Добавить(Элемент);
			КонецЕсли;
		КонецЦикла;
	Иначе
		МассивТипов.Добавить(СсылкаИлиТипИлиМассив);
		Если ИспользоватьШироковещательноеОповещение Тогда
			Если ТипСсылкиИлиТипаИлиМассива = Тип("Тип") Тогда
				ТипЭлемента = СсылкаИлиТипИлиМассив;
			Иначе
				ТипЭлемента = ТипСсылкиИлиТипаИлиМассива;
			КонецЕсли;
			МассивСсылокВРазрезахТипов.Вставить(ТипЭлемента, Новый Массив);
			Если ТипСсылкиИлиТипаИлиМассива <> Тип("Тип") Тогда
				МассивСсылокВРазрезахТипов[ТипЭлемента].Добавить(ТипСсылкиИлиТипаИлиМассива);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ИспользоватьШироковещательноеОповещение Тогда
		Для Каждого КлючИЗначение Из МассивСсылокВРазрезахТипов Цикл
			ОповеститьОткрытыеФормы(Результат, КлючИЗначение.Ключ, ПараметрОповещенияФорм, КлючИЗначение.Значение);
		КонецЦикла;
	КонецЕсли;
	
	ДобавитьШаг(Результат, "ОповеститьДинамическиеСписки", Новый Структура("МассивТипов", МассивТипов));
КонецПроцедуры

// Добавляет в структуру информацию об узлах дерева, которые необходимо "развернуть".
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   ИмяТаблицы - Строка - Имя таблицы формы (дерева значений), в которой требуется развернуть узел.
//   Идентификатор - Произвольный - Необязательный. Идентификатор строки дерева, которую требуется развернуть.
//       Если указано "*", то будут развернуты все узлы верхнего уровня.
//       Если указано Неопределено, то строки дерева развернуты не будут.
//       Значение по умолчанию: "*".
//   СПодчиненными - Булево - Необязательный. Раскрывать ли подчиненные узлы.
//       Значение по умолчанию: Ложь (не раскрывать подчиненные узлы).
//
Процедура РазвернутьУзлыДерева(Результат, ИмяТаблицы, Идентификатор = "*", СПодчиненными = Ложь) Экспорт
	Если ИмяТаблицы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РазворачиваемыйУзел = Новый Структура("ИмяТаблицы, Идентификатор, СПодчиненными");
	РазворачиваемыйУзел.ИмяТаблицы = ИмяТаблицы;
	РазворачиваемыйУзел.Идентификатор = Идентификатор;
	РазворачиваемыйУзел.СПодчиненными = СПодчиненными;
	
	ДобавитьШаг(Результат, "РазвернутьУзлыДерева", РазворачиваемыйУзел);
КонецПроцедуры

// Добавляет в структуру информацию, необходимую для вывода предупреждения или текста ошибки.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   Текст               - Строка - Текст предупреждения.
//   Подробно            - Строка - Необязательный. Тексты ошибок, которые при желании может просмотреть пользователь.
//   Заголовок           - Строка - Необязательный. Заголовок окна.
//   ПутьКРеквизитуФормы - Строка - Необязательный. Путь к реквизиту формы, значение которого вызывало ошибку.
//
Процедура ВывестиПредупреждение(Результат, Текст, Подробно = "", Заголовок = "", ПутьКРеквизитуФормы = "") Экспорт
	Если ПустаяСтрока(Текст) Тогда
		Возврат;
	КонецЕсли;
	
	ВыводПредупреждения = Новый Структура("Заголовок, Текст, ПутьКРеквизитуФормы, Подробно");
	ВыводПредупреждения.Заголовок = Заголовок;
	ВыводПредупреждения.Текст = Текст;
	ВыводПредупреждения.Подробно = Подробно;
	ВыводПредупреждения.ПутьКРеквизитуФормы = ПутьКРеквизитуФормы;
	
	ДобавитьШаг(Результат, "ВывестиПредупреждение", ВыводПредупреждения);
КонецПроцедуры

// Добавляет в структуру информацию, необходимую для вывода сообщения о неверно заполненных полях формы.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   Текст               - Строка - Текст сообщения.
//   ПутьКРеквизитуФормы - Строка - Необязательный. Путь к реквизиту формы, значение которого вызывало ошибку.
//
Процедура ВывестиСообщение(Результат, Текст, ПутьКРеквизитуФормы = "") Экспорт
	Если ПустаяСтрока(Текст) Тогда
		Возврат;
	КонецЕсли;
	
	ВыводСообщения = Новый Структура("Текст, ПутьКРеквизитуФормы");
	ВыводСообщения.Текст = Текст;
	ВыводСообщения.ПутьКРеквизитуФормы = ПутьКРеквизитуФормы;
	
	ДобавитьШаг(Результат, "ВывестиСообщение", ВыводСообщения);
КонецПроцедуры

// Добавляет в структуру информацию, необходимую для вывода всплывающего оповещения.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   Заголовок - Строка - Заголовок оповещения. Чтобы выводилась вся строка рекомендуется длина 40 или меньше.
//       См. также в синтакс-помощнике описание метода глобального контекста "ПоказатьОповещениеПользователя",
//       параметр "Текст".
//   Текст - Строка - Текст оповещения. Чтобы выводилась вся строка рекомендуется длина 40 или меньше.
//       См. также в синтакс-помощнике описание метода глобального контекста "ПоказатьОповещениеПользователя",
//       параметр "Пояснение".
//   Ссылка - Строка - Навигационная ссылка для перехода к объекту конфигурации.
//       См. также в синтакс-помощнике описание метода глобального контекста "ПоказатьОповещениеПользователя",
//       параметр "НавигационнаяСсылка".
//   Картинка - Картинка - Картинка оповещения.
//       См. также в синтакс-помощнике описание метода глобального контекста "ПоказатьОповещениеПользователя",
//       параметр "Картинка".
//
Процедура ВывестиОповещение(Результат, Заголовок, Текст = "", Картинка = Неопределено, Ссылка = "") Экспорт
	Если ПустаяСтрока(Заголовок) И ПустаяСтрока(Текст) Тогда
		Возврат;
	КонецЕсли;
	
	ВыводОповещения = Новый Структура("Заголовок, Ссылка, Текст, Картинка");
	ВыводОповещения.Заголовок = Заголовок;
	ВыводОповещения.Ссылка    = Ссылка;
	ВыводОповещения.Текст     = Текст;
	ВыводОповещения.Картинка  = Картинка;
	
	ДобавитьШаг(Результат, "ВывестиОповещение", ВыводОповещения);
КонецПроцедуры

// Добавляет в структуру информацию, необходимую для открытия формы.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   ПолноеИмя - Строка    - Полный путь к открываемой форме.
//   Параметры - Структура - Необязательный. Параметры открываемой формы.
//   РежимОкна - РежимОткрытияОкнаФормы  - Необязательный. Блокировать ли окно владельца.
//
Процедура ВывестиФорму(Результат, ПолноеИмя, Параметры = Неопределено, РежимОкна = Неопределено) Экспорт
	Если ПустаяСтрока(ПолноеИмя) Тогда
		Возврат;
	КонецЕсли;
	
	ВыводФормы = Новый Структура("ПолноеИмя, Параметры, РежимОкна");
	ВыводФормы.ПолноеИмя = ПолноеИмя;
	ВыводФормы.Параметры = Параметры;
	ВыводФормы.РежимОкна = РежимОкна;
	
	ДобавитьШаг(Результат, "ВывестиФорму", ВыводФормы);
КонецПроцедуры

// Добавляет в структуру информацию, необходимую для вывода предупреждения и текста ошибки.
//   Действие выполняется на клиенте после вызова СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Результат).
//
// Параметры:
//   Результат          - Структура          - См. СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения().
//   ВводныйТекст       - Строка             - Текст предупреждения.
//   ИнформацияОбОшибке - ИнформацияОбОшибке - Необязательный. Тексты ошибок, которые при желании может просмотреть пользователь.
//
// См. также:
//   СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения().
//
Процедура ВывестиИнформациюОбОшибке(Результат, ВводныйТекст, ИнформацияОбОшибке) Экспорт
	Кратко = ВводныйТекст + Символы.ПС + ИсходнаяПричинаОшибки(ИнформацияОбОшибке);
	Подробно = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	ВывестиПредупреждение(Результат, Кратко, Подробно);
КонецПроцедуры

// Устарела. Следует использовать метод глобального контекста Оповестить.
//
// Добавляет в структуру информацию о событии, о котором надо оповестить все открытые формы.
//   Действие выполняется после вызова процедуры СтандартныеПодсистемыКлиент.ПоказатьРезультатВыполнения(Форма, Результат).
//   Для этого структуру Результат следует передать на клиент и передать в соответствующем параметре указанной процедуры.
//
// Параметры:
//   Результат - Структура - Структура, которая может быть использована для передачи информации на клиент.
//       При вызове данного метода в этой структуре будет создан ключ "Шаги":
//       * Шаги - СписокЗначений - Необязательный. Список, в который будет добавлена информация для вывода на клиенте.
//       Структуру Результат допустимо использовать для хранения параметров вызывающего кода,
//       но при этом следует контролировать чтобы вызывающий код не использовал ключ "Шаги",
//       поскольку он зарезервирован для хранения и вывода результата выполнения.
//   ИмяСобытия - Строка - Имя события, которое используется для первичной идентификации сообщения принимающими формами.
//   Параметр   - Произвольный - Набор данных, который может использоваться принимающей формой для обновления.
//   Источник   - Произвольный - Источник оповещения.
//
Процедура ОповеститьОткрытыеФормы(Результат, Знач ИмяСобытия, Знач Параметр = Неопределено, Знач Источник = Неопределено) Экспорт
	Если ИмяСобытия = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если ТипЗнч(ИмяСобытия) = Тип("Тип") Тогда
		#Если Сервер Тогда
			ОбъектМетаданных = Метаданные.НайтиПоТипу(ИмяСобытия);
			Если ТипЗнч(ОбъектМетаданных) <> Тип("ОбъектМетаданных") Тогда
				Возврат;
			КонецЕсли;
			ИмяСобытия = "Запись_" + ОбъектМетаданных.Имя;
			Если Параметр = Неопределено Тогда
				Попытка
					Параметр = ПредопределенноеЗначение(ОбъектМетаданных.ПолноеИмя() + ".ПустаяСсылка");
				Исключение
					Параметр = Неопределено;
				КонецПопытки;
			КонецЕсли;
		#Иначе
			Возврат;
		#КонецЕсли
	КонецЕсли;
	
	ОповещениеФорм = Новый Структура("ИмяСобытия, Параметр, Источник");
	ОповещениеФорм.ИмяСобытия = ИмяСобытия;
	ОповещениеФорм.Параметр = Параметр;
	ОповещениеФорм.Источник = Источник;
	
	ДобавитьШаг(Результат, "ОповеститьОткрытыеФормы", ОповещениеФорм);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Табличный документ

// Рассчитывает показатели числовых ячеек в табличном документе.
//
// Параметры:
//   ТабличныйДокумент - ТабличныйДокумент - Таблица, для которой требуется расчет.
//   ВыделенныеОбласти
//       - Неопределено - При вызове с клиента этот параметр будет определен автоматически.
//       - Массив - При вызове с сервера в этот параметр следует передавать области,
//           предварительно вычисленные на клиенте
//           при помощи функции ОтчетыКлиент.ВыделенныеОбласти(ТабличныйДокумент).
//
// Возвращаемое значение:
//   Структура - Результаты расчета выделенных ячеек.
//       * Количество         - Число - Количество выделенных ячеек.
//       * КоличествоЧисловых - Число - Количество числовых ячеек.
//       * Сумма      - Число - Сумма выделенных ячеек с числами.
//       * Среднее    - Число - Сумма выделенных ячеек с числами.
//       * Минимум    - Число - Сумма выделенных ячеек с числами.
//       * Максимум   - Число - Максимум выделенных ячеек с числами.
//       * НуженВызовСервера - Булево - Истина когда вычисление на клиенте нецелесообразно и нужен вызов сервера.
//
// См. также:
//   ОтчетыКлиент.ВыделенныеОбласти().
//
Функция РасчетЯчеек(ТабличныйДокумент, ВыделенныеОбласти) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Количество", 0);
	Результат.Вставить("КоличествоНеПустых", 0);
	Результат.Вставить("КоличествоЧисловых", 0);
	Результат.Вставить("Сумма", 0);
	Результат.Вставить("Среднее", 0);
	Результат.Вставить("Минимум", Неопределено);
	Результат.Вставить("Максимум", Неопределено);
	Результат.Вставить("НуженВызовСервера", Ложь);
	
	Если ВыделенныеОбласти = Неопределено Тогда
		#Если Клиент Тогда
			ВыделенныеОбласти = ТабличныйДокумент.ВыделенныеОбласти;
		#Иначе
			ВызватьИсключение НСтр("ru = 'Не указано значение параметра ""ВыделенныеОбласти"".'");
		#КонецЕсли
	КонецЕсли;
	
	ПроверенныеЯчейки = Новый Соответствие;
	
	Для Каждого ВыделеннаяОбласть Из ВыделенныеОбласти Цикл
		Если ТипЗнч(ВыделеннаяОбласть) <> Тип("ОбластьЯчеекТабличногоДокумента")
			И ТипЗнч(ВыделеннаяОбласть) <> Тип("Структура") Тогда
			Продолжить;
		КонецЕсли;
		
		ВыделеннаяОбластьВерх  = ВыделеннаяОбласть.Верх;
		ВыделеннаяОбластьНиз   = ВыделеннаяОбласть.Низ;
		ВыделеннаяОбластьЛево  = ВыделеннаяОбласть.Лево;
		ВыделеннаяОбластьПраво = ВыделеннаяОбласть.Право;
		
		Если ВыделеннаяОбластьВерх = 0 Тогда
			ВыделеннаяОбластьВерх = 1;
		КонецЕсли;
		
		Если ВыделеннаяОбластьНиз = 0 Тогда
			ВыделеннаяОбластьНиз = ТабличныйДокумент.ВысотаТаблицы;
		КонецЕсли;
		
		Если ВыделеннаяОбластьЛево = 0 Тогда
			ВыделеннаяОбластьЛево = 1;
		КонецЕсли;
		
		Если ВыделеннаяОбластьПраво = 0 Тогда
			ВыделеннаяОбластьПраво = ТабличныйДокумент.ШиринаТаблицы;
		КонецЕсли;
		
		Если ВыделеннаяОбласть.ТипОбласти = ТипОбластиЯчеекТабличногоДокумента.Колонки Тогда
			ВыделеннаяОбластьВерх = ВыделеннаяОбласть.Низ;
			ВыделеннаяОбластьНиз = ТабличныйДокумент.ВысотаТаблицы;
		КонецЕсли;
		
		ВыделеннаяОбластьВысота = ВыделеннаяОбластьНиз   - ВыделеннаяОбластьВерх + 1;
		ВыделеннаяОбластьШирина = ВыделеннаяОбластьПраво - ВыделеннаяОбластьЛево + 1;
		
		Результат.Количество = Результат.Количество + ВыделеннаяОбластьШирина * ВыделеннаяОбластьВысота;
		#Если Клиент И Не ТолстыйКлиентОбычноеПриложение Тогда
			Если Результат.Количество >= 1000 Тогда
				Результат.НуженВызовСервера = Истина;
				Возврат Результат;
			КонецЕсли;
		#КонецЕсли
		
		Для НомерКолонки = ВыделеннаяОбластьЛево По ВыделеннаяОбластьПраво Цикл
			Для НомерСтроки = ВыделеннаяОбластьВерх По ВыделеннаяОбластьНиз Цикл
				Ячейка = ТабличныйДокумент.Область(НомерСтроки, НомерКолонки, НомерСтроки, НомерКолонки);
				Если ПроверенныеЯчейки.Получить(Ячейка.Имя) = Неопределено Тогда
					ПроверенныеЯчейки.Вставить(Ячейка.Имя, Истина);
				Иначе
					Продолжить;
				КонецЕсли;
				
				Если Ячейка.Видимость = Истина Тогда
					Если Ячейка.ТипОбласти <> ТипОбластиЯчеекТабличногоДокумента.Колонки
						И Ячейка.СодержитЗначение И ТипЗнч(Ячейка.Значение) = Тип("Число") Тогда
						Число = Ячейка.Значение;
					ИначеЕсли ЗначениеЗаполнено(Ячейка.Текст) Тогда
						Число = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(Ячейка.Текст);
					Иначе
						Продолжить;
					КонецЕсли;
					Результат.КоличествоНеПустых = Результат.КоличествоНеПустых + 1;
					Если ТипЗнч(Число) = Тип("Число") Тогда
						Результат.КоличествоЧисловых = Результат.КоличествоЧисловых + 1;
						Результат.Сумма = Результат.Сумма + Число;
						Если Результат.КоличествоЧисловых = 1 Тогда
							Результат.Минимум  = Число;
							Результат.Максимум = Число;
						Иначе
							Результат.Минимум  = Мин(Число,  Результат.Минимум);
							Результат.Максимум = Макс(Число, Результат.Максимум);
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Если Результат.КоличествоЧисловых > 0 Тогда
		Результат.Среднее = Результат.Сумма / Результат.КоличествоЧисловых;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Работа с ошибками.

// Формирует краткое представление исходной проблемы из информации об ошибке.
//
// Параметры:
//   ИнформацияОбОшибке - ИнформацияОбОшибке - Информация об ошибке.
//
// Возвращаемое значение:
//   Строка - Краткое представление ошибки.
//
Функция ИсходнаяПричинаОшибки(ИнформацияОбОшибке) Экспорт
	ОписаниеОшибки = ИнформацияОбОшибке.Описание;
	ПричинаОшибки = ИнформацияОбОшибке.Причина;
	Пока ПричинаОшибки <> Неопределено Цикл
		ОписаниеОшибки = ПричинаОшибки.Описание;
		ПричинаОшибки = ПричинаОшибки.Причина;
	КонецЦикла;
	Возврат ОписаниеОшибки;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Регистрация результата работы для последующего вывода на клиенте.

// Регистрирует сведения для вывода информации.
Процедура ДобавитьШаг(Результат, ИмяПроцедуры, ПараметрыПроцедуры)
	Если Не Результат.Свойство("Шаги") Тогда
		Результат.Вставить("Шаги", Новый СписокЗначений);
	КонецЕсли;
	Результат.Шаги.Добавить(ПараметрыПроцедуры, ИмяПроцедуры);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Работа со строками (кандидат для строковых функций).

// Определяет примерное число строк с учетом переносов.
Функция ЧислоСтрок(Текст, ОтсечкаПоШирине, ПриводитьКРазмерамЭлементовФормы = Истина) Экспорт
	ЧислоСтрок = СтрЧислоСтрок(Текст);
	ЧислоПереносов = 0;
	Для НомерСтроки = 1 По ЧислоСтрок Цикл
		Строка = СтрПолучитьСтроку(Текст, НомерСтроки);
		ЧислоПереносов = ЧислоПереносов + Цел(СтрДлина(Строка)/ОтсечкаПоШирине);
	КонецЦикла;
	ПримерноеЧислоСтрок = ЧислоСтрок + ЧислоПереносов;
	Если ПриводитьКРазмерамЭлементовФормы Тогда
		Если ТекущийВариантИнтерфейсаКлиентскогоПриложения() = ВариантИнтерфейсаКлиентскогоПриложения.Версия8_2 Тогда
			Коэффициент = 4/5; // В 8.2 в высоту 4 вмещается примерно 5 строк текста.
		Иначе
			Коэффициент = 2/3; // В такси в высоту 2 вмещается примерно 3 строки текста.
		КонецЕсли;
		ПримерноеЧислоСтрок = Цел((ПримерноеЧислоСтрок+1)*Коэффициент);
	КонецЕсли;
	Возврат ПримерноеЧислоСтрок;
КонецФункции

#КонецОбласти

