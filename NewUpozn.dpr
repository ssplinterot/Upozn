program NewUpozn;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TTariff = record
    isDeleted: boolean;
    planName: string[50]; // название тарифа
    abonentPlata: real; // Абонентская плата
    includedMinSeti: integer; // Включено минут внутри сети
    includedMinDiffSeti: integer; // Включено минут на другие сети
    includedSMS: integer; // Включено SMS
    includedMMS: integer; // Включено MMS
    includedMB: integer; // Включено мегабайт
    costIncomingRoam: real; // Стоимость входящих минут (роуминг)
    costOutgoingSeti: real; // Стоимость исходящих минут внутри сети
    costOutgoingDiffSeti: real; // Стоимость исходящих минут на другие сети
    costSMS: real; // Стоимость SMS
    costMMS: real; // Стоимость MMS
    costMB: real; // Стоимость мегабайта трафика
  end;

  TTariffList = array of TTariff;

var
  isFileLoaded: boolean = false;

  // Основное меню
procedure ShowMenu;
begin
  writeln('[1] Чтение данных из файла');
  writeln('[2] Просмотр всего списка');
  writeln('[3] Сортировка данных');
  writeln('[4] Поиск данных с использованием фильтров');
  writeln('[5] Добавление данных в список');
  writeln('[6] Удаление данных из списка ');
  writeln('[7] Редактирование данных ');
  writeln('[8] Калькулятор тарифов');
  writeln('[9] Выход из программы без сохранения изменений');
  writeln('[10] Выход с сохранением изменений');
  // write('Введите номер пункта: ');
end;

{ procedure ClearScreen;
  var
  hConsole: THandle;
  cursorPos: TCoord;
  begin
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  Write(#27'[2J'#27'[3J');
  cursorPos.X := 0;
  cursorPos.Y := 0;
  SetConsoleCursorPosition(hConsole, cursorPos);
  end; }

// [1] Чтение данных из файла
procedure ReadDataFromFile(var ATariffList: TTariffList;
  const AFileName: string);
var
  F: file of TTariff;
  i, NumRecords: integer;

begin
  if isFileLoaded then
  begin
    writeln('Файл уже был загружен ранее');
    Exit;
  end;

  if not FileExists(AFileName) then
  begin
    writeln('Файл ', AFileName, ' не найден!');
    Exit;
  end;

  AssignFile(F, AFileName);
  try
    Reset(F);
    NumRecords := FileSize(F);
    SetLength(ATariffList, NumRecords);

    // Читаем данные из файла

    if NumRecords > 0 then
    begin
      for i := 0 to NumRecords - 1 do
      begin
        ATariffList[i].isDeleted := false;
        Read(F, ATariffList[i]);
      end;
    end;

    writeln('Загружено тарифов: ', NumRecords);
    isFileLoaded := true;
  except
    on E: Exception do // Обработка исключений
    begin
      writeln('Ошибка при чтении файла: ', E.Message);
      Exit;
    end;
  end;
finally
  CloseFile(F);
end;

// [2] Просмотр всего списка
procedure SeeAllSpisok(const ATariffList: TTariffList);
var
  i: integer;
  VisibleIndex: integer;
begin
  VisibleIndex := 0;
  if Length(ATariffList) = 0 then
  begin
    writeln('Список пуст');
    readln;
    Exit
  end
  else
  begin
    writeln('==================== Список тарифов =====================');
    writeln('|  №  |       Название     |        Абонт.плата(руб)     |');
    writeln('=========================================================');

    for i := 0 to High(ATariffList) do
    begin
      if ATariffList[i].isDeleted then
        Continue;
      Inc(VisibleIndex);
      writeln(Format('| %-2d | %-19s | %-27.2f |',
        [VisibleIndex, ATariffList[i].planName, ATariffList[i].abonentPlata]));
      writeln('|    | Вкл. минут внутри:    ', ATariffList[i].includedMinSeti:5,
        '                       |');
      writeln('|    | Вкл. минут на др.сети:          ',
        ATariffList[i].includedMinDiffSeti:5, '             |');
      writeln('|    | Включено SMS:                   ',
        ATariffList[i].includedSMS:5, '             |');
      writeln('|    | Включено MMS:                   ',
        ATariffList[i].includedMMS:5, '             |');
      writeln('|    | Включено мегабайт:              ',
        ATariffList[i].includedMB:5, '             |');
      writeln('|    | Стоимость вход.минут (роуминг):     ',
        ATariffList[i].costIncomingRoam:0:0, '             |');
      writeln('|    | Стоимость исход.мин. внутр.сети:    ',
        ATariffList[i].costOutgoingSeti:0:0, '            |');
      writeln('|    | Стоимость исход.мин. на др.сети:    ',
        ATariffList[i].costOutgoingDiffSeti:0:0, '             |');
      writeln('|    | Стоимость SMS:                      ',
        ATariffList[i].costSMS:0:0, '            |');
      writeln('|    | Стоимость MMS:                      ',
        ATariffList[i].costMMS:0:0, '            |');
      writeln('|    | Стоимость мегабайта трафика:        ',
        ATariffList[i].costMB:0:0, '            |');
      writeln('---------------------------------------------------------');
    end;
    readln;
  end;

end;

// [3] Сортировка данных
procedure SelectionSortData(var ATariffList: TTariffList);
var
  i, j, min, choice: integer;
  temp: TTariff;
  // WhatSort: string;
begin
  if Length(ATariffList) = 0 then
  begin
    writeln('Список тарифов пуст!');
    Exit;
  end;
  writeln('Выберите по какому пункту отсортировать:');
  writeln('  0) по названию тарифа');
  writeln('  1) по абонентской плате');
  writeln('  2) по включенным минутам внутри сети');
  writeln('  3) по включенным минутам на другие сети');
  writeln('  4) по включенным SMS');
  writeln('  5) по включенным MMS');
  writeln('  6) по включенным мегабайтам');
  writeln('  7) по стоимости входящих минут (роуминг)');
  writeln('  8) по стоимости исходящих минут внутри сети');
  writeln('  9) по стоимости исходящих минут на другие сети');
  writeln('  10) по стоимости SMS');
  writeln('  11) по стоимости MMS');
  writeln('  12) по стоимости мегабайта трафика');
  writeln('Ваш выбор: ');
  readln(choice);
  for i := 0 to High(ATariffList) - 1 do
  begin
    if ATariffList[i].isDeleted then
      Continue;
    min := i;
    for j := i + 1 to High(ATariffList) do
    begin
      if ATariffList[j].isDeleted then
        Continue;
      case choice of
        0: // название тарифа
          if LowerCase(ATariffList[j].planName) <
            LowerCase(ATariffList[min].planName) then
            min := j;
        1: // Абонентская плата
          if ATariffList[j].abonentPlata < ATariffList[min].abonentPlata then
            min := j;

        2: // Вкл. минут внутри
          if ATariffList[j].includedMinSeti < ATariffList[min].includedMinSeti
          then
            min := j;

        3: // Вкл. минут на др.сети
          if ATariffList[j].includedMinDiffSeti < ATariffList[min].includedMinDiffSeti
          then
            min := j;

        4: // Включено SMS
          if ATariffList[j].includedSMS < ATariffList[min].includedSMS then
            min := j;

        5: // Включено MMS
          if ATariffList[j].includedMMS < ATariffList[min].includedMMS then
            min := j;

        6: // Включено мегабайт
          if ATariffList[j].includedMB < ATariffList[min].includedMB then
            min := j;

        7: // Стоимость вход.минут (роуминг)
          if ATariffList[j].costIncomingRoam < ATariffList[min].costIncomingRoam
          then
            min := j;

        8: // Стоимость исход.мин. внутр.сети
          if ATariffList[j].costOutgoingSeti < ATariffList[min].costOutgoingSeti
          then
            min := j;

        9: // Стоимость исход.мин. на др.сети
          if ATariffList[j].costOutgoingDiffSeti < ATariffList[min].costOutgoingDiffSeti
          then
            min := j;

        10: // Стоимость SMS
          if ATariffList[j].costSMS < ATariffList[min].costSMS then
            min := j;

        11: // Стоимость MMS
          if ATariffList[j].costMMS < ATariffList[min].costMMS then
            min := j;

        12: // Стоимость мегабайта трафика
          if ATariffList[j].costMB < ATariffList[min].costMB then
            min := j;
      end;
    end;
    if min <> i then
    begin
      temp := ATariffList[i];
      ATariffList[i] := ATariffList[min];
      ATariffList[min] := temp;
    end;
  end;
  writeln('Cортировка совершена');

  writeln('==================== Список тарифов =====================');
  writeln('|  №  |       Название     |        Абонт.плата(руб)     |');
  writeln('=========================================================');

  for i := 0 to High(ATariffList) do
  begin
    writeln(Format('| %-2d | %-19s | %-27.2f |',
      [i + 1, ATariffList[i].planName, ATariffList[i].abonentPlata]));
    writeln('|    | Вкл. минут внутри:    ', ATariffList[i].includedMinSeti:5,
      '                       |');
    writeln('|    | Вкл. минут на др.сети:          ',
      ATariffList[i].includedMinDiffSeti:5, '             |');
    writeln('|    | Включено SMS:                   ',
      ATariffList[i].includedSMS:5, '             |');
    writeln('|    | Включено MMS:                   ',
      ATariffList[i].includedMMS:5, '             |');
    writeln('|    | Включено мегабайт:              ', ATariffList[i].includedMB
      :5, '             |');
    writeln('|    | Стоимость вход.минут (роуминг):     ',
      ATariffList[i].costIncomingRoam:0:0, '           |');
    writeln('|    | Стоимость исход.мин. внутр.сети:    ',
      ATariffList[i].costOutgoingSeti:0:0, '            |');
    writeln('|    | Стоимость исход.мин. на др.сети:    ',
      ATariffList[i].costOutgoingDiffSeti:0:0, '           |');
    writeln('|    | Стоимость SMS:                      ',
      ATariffList[i].costSMS:0:0, '            |');
    writeln('|    | Стоимость MMS:                      ',
      ATariffList[i].costMMS:0:0, '            |');
    writeln('|    | Стоимость мегабайта трафика:        ', ATariffList[i].costMB
      :0:0, '            |');
    writeln('---------------------------------------------------------');
  end;
  readln;
end;

// [4] Поиск данных с использованием фильтров
procedure SearchData(const ATariffList: TTariffList);
var
  i, choice: integer;
  Found: boolean;
  SearchStr: string;
  MinValue, MaxValue: real;
  FilterList: TTariffList;
begin
  if Length(ATariffList) = 0 then
  begin
    writeln('Список тарифов пуст!');
    Exit;
  end;

  writeln('Выберите критерий поиска:');
  writeln('1) По названию тарифа');
  writeln('2) По абонентской плате (диапазон)');
  write('Ваш выбор: ');
  readln(choice);

  SetLength(FilterList, 0);
  Found := false;

  case choice of
    1: // название тарифа
      begin
        write('Ведите название тарифа: ');
        readln(SearchStr);

        for i := 0 to High(ATariffList) do
        begin
          if ATariffList[i].isDeleted then
            Continue;
          if Pos(LowerCase(SearchStr), LowerCase(ATariffList[i].planName)) > 0
          then
          begin
            // SetLength(FilterList, ATariffList + 1);
            Insert(ATariffList[i], FilterList, Length(FilterList));
            Found := true;
          end;
        end;
      end;
    2: // по абонент. плате
      begin
        write('введите минимальную абонентскую плату: ');
        readln(MinValue);
        write('введите максимальную абонентскую плату: ');
        readln(MaxValue);

        for i := 0 to High(ATariffList) do
        begin
          if (ATariffList[i].abonentPlata >= MinValue) and
            (ATariffList[i].abonentPlata <= MaxValue) and not ATariffList[i].isDeleted
          then
          begin
            // SetLength(FilterList, ATariffList + 1);
            Insert(ATariffList[i], FilterList, Length(FilterList));
            Found := true;
          end;
        end;

      end

  else
    writeln('Такого пункта не существует');
    Exit;
  end;
  if Found then
  begin
    writeln('Найдено тарифов: ', Length(FilterList));
    SeeAllSpisok(FilterList);
  end
  else
    writeln('Тарифы не найдены');

  SetLength(FilterList, 0);
  readln;
end;

// [5] Добавление данных в список
procedure AddDataInList(var ATariffList: TTariffList);
var
  NewTariff: TTariff;
  len, i: integer;
  IsUnique, isValid: boolean;
  inputStr: string;
begin
  SetLength(ATariffList, Length(ATariffList) + 1);
  NewTariff.isDeleted := false;
  repeat
    write('Введите название тарифа: ');
    readln(NewTariff.planName);
    IsUnique := true;
    for i := 0 to High(ATariffList) do
    begin
      if LowerCase(ATariffList[i].planName) = LowerCase(NewTariff.planName) then
      begin
        IsUnique := false;
        writeln('Тариф с таким названием уже существует, введите пожалуйста другое');
      end;
    end;
  until IsUnique;

  repeat
    isValid := true;
    write('Абонентская плата: ');
    readln(inputStr);
    NewTariff.abonentPlata := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.abonentPlata := NewTariff.abonentPlata * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Включено минут внутри сети: ');
    readln(inputStr);
    NewTariff.includedMinSeti := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.includedMinSeti := NewTariff.includedMinSeti * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Включено минут на другие сети: ');
    readln(inputStr);
    NewTariff.includedMinDiffSeti := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.includedMinDiffSeti := NewTariff.includedMinDiffSeti * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Включено SMS: ');
    readln(inputStr);
    NewTariff.includedSMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.includedSMS := NewTariff.includedSMS * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Включено MMS: ');
    readln(inputStr);
    NewTariff.includedMMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.includedMMS := NewTariff.includedMMS * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Включено мегабайт: ');
    readln(inputStr);
    NewTariff.includedMB := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.includedMB := NewTariff.includedMB * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Стоимость входящих минут (роуминг):');
    readln(inputStr);
    NewTariff.costIncomingRoam := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.costIncomingRoam := NewTariff.costIncomingRoam * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Стоимость исходящих минут внутри сети:');
    readln(inputStr);
    NewTariff.costOutgoingSeti := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.costOutgoingSeti := NewTariff.costOutgoingSeti * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Стоимость SMS:');
    readln(inputStr);
    NewTariff.costSMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.costSMS := NewTariff.costSMS * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Стоимость MMS:');
    readln(inputStr);
    NewTariff.costMMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.costMMS := NewTariff.costMMS * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    write('Стоимость мегабайта трафика: ');
    readln(inputStr);
    NewTariff.costMB := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      NewTariff.costMB := NewTariff.costMB * 10 + (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  ATariffList[High(ATariffList)] := NewTariff;
  writeln('Тариф ', NewTariff.planName, ' добавлен');
  readln;
end;

// [6] Удаление данных из списка
procedure DeleteTariff(var ATariffList: TTariffList);
var
  i, Index, VisibleIndex, UserIndex, RealIndex: integer;
begin
  VisibleIndex := 0;
  if Length(ATariffList) = 0 then
  begin
    writeln('Список тарифов пуст!');
    Exit;
  end;

  writeln('Список доступных тарифов: ');
  VisibleIndex := 0;
  for i := 0 to High(ATariffList) do
  begin
    if not ATariffList[i].isDeleted then
    begin
      Inc(VisibleIndex);
      writeln('[', VisibleIndex, ']  ', ATariffList[i].planName);
    end;
  end;

  // Получаем корректный индекс от пользователя
  repeat
    write('Введите номер для удаления: ');
    readln(UserIndex);
  until (UserIndex >= 1) and (UserIndex <= VisibleIndex);

  // Находим реальный индекс в массиве
  RealIndex := -1;
  VisibleIndex := 0;
  for i := 0 to High(ATariffList) do
  begin
    if not ATariffList[i].isDeleted then
    begin
      Inc(VisibleIndex);
      if VisibleIndex = UserIndex then
      begin
        RealIndex := i;
        break;
      end;
    end;
  end;

  if RealIndex = -1 then
  begin
    writeln('Ошибка удаления!');
    Exit;
  end;

  // Помечаем запись как удаленную
  ATariffList[RealIndex].isDeleted := true;
  writeln('Тариф "', ATariffList[RealIndex].planName, '" удалён');
end;

// [7] Редактирование данных(абонентской платы)
procedure ChangeData(var ATariffList: TTariffList);
var
  isValid: boolean;
  i: integer;
  tempChIndex, tarifIndex: integer;
  inputStr: string;
  newValue: double;
  // newValue: real;
begin
  if Length(ATariffList) = 0 then
  begin
    writeln('Список тарифов пуст!');
    Exit;
  end;

  writeln('==================== Список доступных тарифов =====================');
  for i := 0 to High(ATariffList) do
    writeln(' ', i + 1, ') ', ATariffList[i].planName);

  repeat
    isValid := true;
    write('Выберите тариф для редактирования абонент.платы: ');
    readln(inputStr);

    tarifIndex := 0;
    for tempChIndex := 1 to Length(inputStr) do
    // перебор каждого символа в строке

    begin
      if not(inputStr[tempChIndex] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      tarifIndex := tarifIndex * 10 + (Ord(inputStr[tempChIndex]) - Ord('0'));
    end;
    tarifIndex := tarifIndex - 1;
    if not isValid or (tarifIndex < 0) or (tarifIndex > High(ATariffList)) then
    begin
      writeln('Ошибка: такого номера не существует');
      isValid := false;
    end;
  until isValid;

  repeat
    write('Ведите новое значение для абонентской платы(текущее значение ',
      ATariffList[tarifIndex].abonentPlata: 0: 2, '): ');
    readln(inputStr);
    isValid := TryStrToFloat(inputStr, newValue);
    if not isValid then
      write('Ошибка: введите корректное число: ');
  until isValid;

  ATariffList[tarifIndex].abonentPlata := newValue;
  writeln('Абонентская плата изменена на ', newValue:0:2);
  readln;
end;

// [8] Калькулятор тарифов
procedure CalculateTariffs(const ATariffList: TTariffList;
  const AFileName: string);
var
  i, minIndex, j: integer;
  F: TextFile;
  usedAbonentPlata, usedIncludedMinSeti, usedIncludedMinDiffSeti,
    usedIncludedSMS, usedIncludedMMS, usedIncludedMB: integer;
  isValid: boolean;
  inputStr, TempNames: string;
  tariffsNames: array of string;
  tariffsCoasts: array of real;
  totalCoasts, extraMinutes, extraSMS, extraMMS, exstraMB, TempCost: real;

begin
  isValid := true;
  if Length(ATariffList) = 0 then
  begin
    writeln('Список тарифов пуст!');
    Exit;
  end;

  writeln('===========Введите нужные средние значения за месяц==========');

  writeln('Ведите нужный вам месячный расход: ');
  repeat
    isValid := true;
    Write('Количество абонентской платы: ');
    readln(inputStr);
    usedAbonentPlata := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedAbonentPlata := usedAbonentPlata * 10 + (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    Write('Минуты внутри сети: ');
    readln(inputStr);
    usedIncludedMinSeti := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedIncludedMinSeti := usedIncludedMinSeti * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    Write('Минуты на другие сети: ');
    readln(inputStr);
    usedIncludedMinDiffSeti := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedIncludedMinDiffSeti := usedIncludedMinDiffSeti * 10 +
        (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    Write('Включено SMS: ');
    readln(inputStr);
    usedIncludedSMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedIncludedSMS := usedIncludedSMS * 10 + (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    Write('Включено MMS: ');
    readln(inputStr);
    usedIncludedMMS := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedIncludedMMS := usedIncludedMMS * 10 + (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  repeat
    isValid := true;
    Write('Включено мегабайтов: ');
    readln(inputStr);
    usedIncludedMB := 0;
    if Length(inputStr) = 0 then
      isValid := false;
    for i := 1 to Length(inputStr) do
    begin
      if not(inputStr[i] in ['0' .. '9']) then
      begin
        isValid := false;
        break;
      end;
      usedIncludedMB := usedIncludedMB * 10 + (Ord(inputStr[i]) - Ord('0'));
    end;
    if not isValid then
      writeln('Ошибка: введите число');
  until isValid;

  SetLength(tariffsNames, 0);
  SetLength(tariffsCoasts, 0);
  for i := 0 to High(ATariffList) do
  begin
    if ATariffList[i].isDeleted then
      Continue;
    SetLength(tariffsNames, Length(tariffsNames) + 1);
SetLength(tariffsCoasts, Length(tariffsCoasts) + 1);
tariffsNames[High(tariffsNames)] := ATariffList[i].planName; // <-- Исправлено
tariffsCoasts[High(tariffsCoasts)] := totalCoasts;

    if usedIncludedMinSeti > ATariffList[i].includedMinSeti then
    begin
      extraMinutes := usedIncludedMinSeti - ATariffList[i].includedMinSeti;
      totalCoasts := totalCoasts + extraMinutes * ATariffList[i]
        .costOutgoingSeti;
    end;

    if usedIncludedMinDiffSeti > ATariffList[i].includedMinDiffSeti then
    begin
      extraMinutes := usedIncludedMinDiffSeti - ATariffList[i]
        .includedMinDiffSeti;
      totalCoasts := totalCoasts + extraMinutes * ATariffList[i]
        .costOutgoingDiffSeti;
    end;

    if usedIncludedSMS > ATariffList[i].includedSMS then
    begin
      extraMinutes := usedIncludedSMS - ATariffList[i].includedSMS;
      totalCoasts := totalCoasts + extraMinutes * ATariffList[i].costSMS;
    end;

    if usedIncludedMMS > ATariffList[i].includedMMS then
    begin
      extraMinutes := usedIncludedMMS - ATariffList[i].includedMMS;
      totalCoasts := totalCoasts + extraMinutes * ATariffList[i].costMMS;
    end;

    if usedIncludedMB > ATariffList[i].includedMB then
    begin
      extraMinutes := usedIncludedMB - ATariffList[i].includedMB;
      totalCoasts := totalCoasts + extraMinutes * ATariffList[i].costMB;
    end;

    tariffsNames[i] := ATariffList[i].planName;
    tariffsCoasts[i] := totalCoasts;
  end;

  // Сортировка прямым выбором
  for i := 0 to High(tariffsCoasts) - 1 do
  begin
    if ATariffList[i].isDeleted then
      Continue;
    minIndex := i;
    for j := i + 1 to High(tariffsCoasts) do
    begin
      if ATariffList[i].isDeleted then
        Continue;
      if tariffsCoasts[j] < tariffsCoasts[minIndex] then
        minIndex := j;
    end;

    if minIndex <> i then
    begin
      // Обмен стоимостями
      TempCost := tariffsCoasts[i];
      tariffsCoasts[i] := tariffsCoasts[minIndex];
      tariffsCoasts[minIndex] := TempCost;

      // Обмен названиями
      TempNames := tariffsNames[i];
      tariffsNames[i] := tariffsNames[minIndex];
      tariffsNames[minIndex] := TempNames;
    end;
  end;

  // Вывод результатов
  writeln('Результаты расчета:');
  writeln('================================================');
  for i := 0 to High(tariffsNames) do
    writeln('[', i + 1, '] ', tariffsNames[i], ': ', tariffsCoasts[i]:0
      :2, ' руб.');

  // Запись в файл
  AssignFile(F, AFileName);
  try
    Rewrite(F);
    writeln(F, 'Результаты расчета:');
    for i := 0 to High(tariffsNames) do
      writeln(F, tariffsNames[i], ';', tariffsCoasts[i]:0:2);
    writeln('Данные сохранены в файл: ', AFileName);
  except
    writeln('Ошибка записи в файл!');
  end;
  CloseFile(F);

  readln;
end;

// [10] Выход с сохранением изменений
procedure SaveFileToData(const ATariffList: TTariffList;
  const AFileName: string);
var
  F: file of TTariff;
  i: integer;
  TempList: TTariffList;
begin

  SetLength(TempList, 0);
  for i := 0 to High(ATariffList) do
  begin
    if not ATariffList[i].isDeleted then
    begin
      SetLength(TempList, Length(TempList) + 1);
      TempList[High(TempList)] := ATariffList[i];
    end;
  end;

  AssignFile(F, AFileName);
  try
    Rewrite(F);
    for i := 0 to High(ATariffList) do
      if not ATariffList[i].isDeleted then
        Write(F, ATariffList[i]);
    writeln('Данные сохранены в файл: ', AFileName);
  finally
    CloseFile(F);
  end;
end;

var
  tariffList: TTariffList;
  choice: integer;
  running: boolean;
  isValid: boolean;
  inputStr: string;

begin
  running := true;
  while running do
  begin
    writeln('=========================================================');
    ShowMenu;
    repeat
      write('Введите номер пункта: ');
      readln(inputStr);
      isValid := TryStrToInt(inputStr, choice);
      if not isValid or (choice < 1) or (choice > 10) then
        writeln('Ошибка: введите число от 1 до 10.');
    until isValid and (choice >= 1) and (choice <= 10);

    case choice of
      1:
        ReadDataFromFile(tariffList, 'tarrifs.dat');
      2:
        SeeAllSpisok(tariffList);
      3:
        SelectionSortData(tariffList);
      4:
        SearchData(tariffList);
      5:
        AddDataInList(tariffList);
      6:
        DeleteTariff(tariffList);
      7:
        ChangeData(tariffList);
      8:
        CalculateTariffs(tariffList, 'results.txt');
      9:
        running := false;
      10:
        begin
          SaveFileToData(tariffList, 'tarrifs.dat');
          running := false;
        end
    else
      writeln('Введите правильный пункт');
    end;
    { readln(choice);
      if choice = 1 then
      ReadDataFromFile(tariffList, 'tarrifs.dat')
      else if choice = 2 then
      SeeAllSpisok(tariffList)
      else if choice = 3 then
      SelectionSortData(tariffList)
      else if choice = 4 then
      SearchData(tariffList)
      else if choice = 5 then
      AddDataInList(tariffList)
      else if choice = 6 then
      DeleteTariff(tariffList)
      else if choice = 7 then
      ChangeData(tariffList)
      else if choice = 8 then
      CalculateTariffs(tariffList, 'results.txt')
      else if choice = 9 then
      running := false
      else if choice = 10 then
      begin
      SaveFileToData(tariffList, 'tarrifs.dat');
      running := false;
      end
      else
      writeln('Введите правильный пункт'); }
    writeln;
  end;
  readln;

end.
