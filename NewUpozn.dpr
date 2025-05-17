program NewUpozn;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type
  TTariff = record
    isDeleted: boolean;
    planName: string[50]; // �������� ������
    abonentPlata: real; // ����������� �����
    includedMinSeti: integer; // �������� ����� ������ ����
    includedMinDiffSeti: integer; // �������� ����� �� ������ ����
    includedSMS: integer; // �������� SMS
    includedMMS: integer; // �������� MMS
    includedMB: integer; // �������� ��������
    costIncomingRoam: real; // ��������� �������� ����� (�������)
    costOutgoingSeti: real; // ��������� ��������� ����� ������ ����
    costOutgoingDiffSeti: real; // ��������� ��������� ����� �� ������ ����
    costSMS: real; // ��������� SMS
    costMMS: real; // ��������� MMS
    costMB: real; // ��������� ��������� �������
  end;

  TTariffList = array of TTariff;

var
  isFileLoaded: boolean = false;

  // �������� ����
procedure ShowMenu;
begin
  writeln('[1] ������ ������ �� �����');
  writeln('[2] �������� ����� ������');
  writeln('[3] ���������� ������');
  writeln('[4] ����� ������ � �������������� ��������');
  writeln('[5] ���������� ������ � ������');
  writeln('[6] �������� ������ �� ������ ');
  writeln('[7] �������������� ������ ');
  writeln('[8] ����������� �������');
  writeln('[9] ����� �� ��������� ��� ���������� ���������');
  writeln('[10] ����� � ����������� ���������');
  // write('������� ����� ������: ');
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

// [1] ������ ������ �� �����
procedure ReadDataFromFile(var ATariffList: TTariffList;
  const AFileName: string);
var
  F: file of TTariff;
  i, NumRecords: integer;

begin
  if isFileLoaded then
  begin
    writeln('���� ��� ��� �������� �����');
    Exit;
  end;

  if not FileExists(AFileName) then
  begin
    writeln('���� ', AFileName, ' �� ������!');
    Exit;
  end;

  AssignFile(F, AFileName);
  try
    Reset(F);
    NumRecords := FileSize(F);
    SetLength(ATariffList, NumRecords);

    // ������ ������ �� �����

    if NumRecords > 0 then
    begin
      for i := 0 to NumRecords - 1 do
      begin
        ATariffList[i].isDeleted := false;
        Read(F, ATariffList[i]);
      end;
    end;

    writeln('��������� �������: ', NumRecords);
    isFileLoaded := true;
  except
    on E: Exception do // ��������� ����������
    begin
      writeln('������ ��� ������ �����: ', E.Message);
      Exit;
    end;
  end;
finally
  CloseFile(F);
end;

// [2] �������� ����� ������
procedure SeeAllSpisok(const ATariffList: TTariffList);
var
  i: integer;
  VisibleIndex: integer;
begin
  VisibleIndex := 0;
  if Length(ATariffList) = 0 then
  begin
    writeln('������ ����');
    readln;
    Exit
  end
  else
  begin
    writeln('==================== ������ ������� =====================');
    writeln('|  �  |       ��������     |        �����.�����(���)     |');
    writeln('=========================================================');

    for i := 0 to High(ATariffList) do
    begin
      if ATariffList[i].isDeleted then
        Continue;
      Inc(VisibleIndex);
      writeln(Format('| %-2d | %-19s | %-27.2f |',
        [VisibleIndex, ATariffList[i].planName, ATariffList[i].abonentPlata]));
      writeln('|    | ���. ����� ������:    ', ATariffList[i].includedMinSeti:5,
        '                       |');
      writeln('|    | ���. ����� �� ��.����:          ',
        ATariffList[i].includedMinDiffSeti:5, '             |');
      writeln('|    | �������� SMS:                   ',
        ATariffList[i].includedSMS:5, '             |');
      writeln('|    | �������� MMS:                   ',
        ATariffList[i].includedMMS:5, '             |');
      writeln('|    | �������� ��������:              ',
        ATariffList[i].includedMB:5, '             |');
      writeln('|    | ��������� ����.����� (�������):     ',
        ATariffList[i].costIncomingRoam:0:0, '             |');
      writeln('|    | ��������� �����.���. �����.����:    ',
        ATariffList[i].costOutgoingSeti:0:0, '            |');
      writeln('|    | ��������� �����.���. �� ��.����:    ',
        ATariffList[i].costOutgoingDiffSeti:0:0, '             |');
      writeln('|    | ��������� SMS:                      ',
        ATariffList[i].costSMS:0:0, '            |');
      writeln('|    | ��������� MMS:                      ',
        ATariffList[i].costMMS:0:0, '            |');
      writeln('|    | ��������� ��������� �������:        ',
        ATariffList[i].costMB:0:0, '            |');
      writeln('---------------------------------------------------------');
    end;
    readln;
  end;

end;

// [3] ���������� ������
procedure SelectionSortData(var ATariffList: TTariffList);
var
  i, j, min, choice: integer;
  temp: TTariff;
  // WhatSort: string;
begin
  if Length(ATariffList) = 0 then
  begin
    writeln('������ ������� ����!');
    Exit;
  end;
  writeln('�������� �� ������ ������ �������������:');
  writeln('  0) �� �������� ������');
  writeln('  1) �� ����������� �����');
  writeln('  2) �� ���������� ������� ������ ����');
  writeln('  3) �� ���������� ������� �� ������ ����');
  writeln('  4) �� ���������� SMS');
  writeln('  5) �� ���������� MMS');
  writeln('  6) �� ���������� ����������');
  writeln('  7) �� ��������� �������� ����� (�������)');
  writeln('  8) �� ��������� ��������� ����� ������ ����');
  writeln('  9) �� ��������� ��������� ����� �� ������ ����');
  writeln('  10) �� ��������� SMS');
  writeln('  11) �� ��������� MMS');
  writeln('  12) �� ��������� ��������� �������');
  writeln('��� �����: ');
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
        0: // �������� ������
          if LowerCase(ATariffList[j].planName) <
            LowerCase(ATariffList[min].planName) then
            min := j;
        1: // ����������� �����
          if ATariffList[j].abonentPlata < ATariffList[min].abonentPlata then
            min := j;

        2: // ���. ����� ������
          if ATariffList[j].includedMinSeti < ATariffList[min].includedMinSeti
          then
            min := j;

        3: // ���. ����� �� ��.����
          if ATariffList[j].includedMinDiffSeti < ATariffList[min].includedMinDiffSeti
          then
            min := j;

        4: // �������� SMS
          if ATariffList[j].includedSMS < ATariffList[min].includedSMS then
            min := j;

        5: // �������� MMS
          if ATariffList[j].includedMMS < ATariffList[min].includedMMS then
            min := j;

        6: // �������� ��������
          if ATariffList[j].includedMB < ATariffList[min].includedMB then
            min := j;

        7: // ��������� ����.����� (�������)
          if ATariffList[j].costIncomingRoam < ATariffList[min].costIncomingRoam
          then
            min := j;

        8: // ��������� �����.���. �����.����
          if ATariffList[j].costOutgoingSeti < ATariffList[min].costOutgoingSeti
          then
            min := j;

        9: // ��������� �����.���. �� ��.����
          if ATariffList[j].costOutgoingDiffSeti < ATariffList[min].costOutgoingDiffSeti
          then
            min := j;

        10: // ��������� SMS
          if ATariffList[j].costSMS < ATariffList[min].costSMS then
            min := j;

        11: // ��������� MMS
          if ATariffList[j].costMMS < ATariffList[min].costMMS then
            min := j;

        12: // ��������� ��������� �������
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
  writeln('C��������� ���������');

  writeln('==================== ������ ������� =====================');
  writeln('|  �  |       ��������     |        �����.�����(���)     |');
  writeln('=========================================================');

  for i := 0 to High(ATariffList) do
  begin
    writeln(Format('| %-2d | %-19s | %-27.2f |',
      [i + 1, ATariffList[i].planName, ATariffList[i].abonentPlata]));
    writeln('|    | ���. ����� ������:    ', ATariffList[i].includedMinSeti:5,
      '                       |');
    writeln('|    | ���. ����� �� ��.����:          ',
      ATariffList[i].includedMinDiffSeti:5, '             |');
    writeln('|    | �������� SMS:                   ',
      ATariffList[i].includedSMS:5, '             |');
    writeln('|    | �������� MMS:                   ',
      ATariffList[i].includedMMS:5, '             |');
    writeln('|    | �������� ��������:              ', ATariffList[i].includedMB
      :5, '             |');
    writeln('|    | ��������� ����.����� (�������):     ',
      ATariffList[i].costIncomingRoam:0:0, '           |');
    writeln('|    | ��������� �����.���. �����.����:    ',
      ATariffList[i].costOutgoingSeti:0:0, '            |');
    writeln('|    | ��������� �����.���. �� ��.����:    ',
      ATariffList[i].costOutgoingDiffSeti:0:0, '           |');
    writeln('|    | ��������� SMS:                      ',
      ATariffList[i].costSMS:0:0, '            |');
    writeln('|    | ��������� MMS:                      ',
      ATariffList[i].costMMS:0:0, '            |');
    writeln('|    | ��������� ��������� �������:        ', ATariffList[i].costMB
      :0:0, '            |');
    writeln('---------------------------------------------------------');
  end;
  readln;
end;

// [4] ����� ������ � �������������� ��������
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
    writeln('������ ������� ����!');
    Exit;
  end;

  writeln('�������� �������� ������:');
  writeln('1) �� �������� ������');
  writeln('2) �� ����������� ����� (��������)');
  write('��� �����: ');
  readln(choice);

  SetLength(FilterList, 0);
  Found := false;

  case choice of
    1: // �������� ������
      begin
        write('������ �������� ������: ');
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
    2: // �� �������. �����
      begin
        write('������� ����������� ����������� �����: ');
        readln(MinValue);
        write('������� ������������ ����������� �����: ');
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
    writeln('������ ������ �� ����������');
    Exit;
  end;
  if Found then
  begin
    writeln('������� �������: ', Length(FilterList));
    SeeAllSpisok(FilterList);
  end
  else
    writeln('������ �� �������');

  SetLength(FilterList, 0);
  readln;
end;

// [5] ���������� ������ � ������
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
    write('������� �������� ������: ');
    readln(NewTariff.planName);
    IsUnique := true;
    for i := 0 to High(ATariffList) do
    begin
      if LowerCase(ATariffList[i].planName) = LowerCase(NewTariff.planName) then
      begin
        IsUnique := false;
        writeln('����� � ����� ��������� ��� ����������, ������� ���������� ������');
      end;
    end;
  until IsUnique;

  repeat
    isValid := true;
    write('����������� �����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('�������� ����� ������ ����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('�������� ����� �� ������ ����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('�������� SMS: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('�������� MMS: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('�������� ��������: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('��������� �������� ����� (�������):');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('��������� ��������� ����� ������ ����:');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('��������� SMS:');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('��������� MMS:');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    write('��������� ��������� �������: ');
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
      writeln('������: ������� �����');
  until isValid;

  ATariffList[High(ATariffList)] := NewTariff;
  writeln('����� ', NewTariff.planName, ' ��������');
  readln;
end;

// [6] �������� ������ �� ������
procedure DeleteTariff(var ATariffList: TTariffList);
var
  i, Index, VisibleIndex, UserIndex, RealIndex: integer;
begin
  VisibleIndex := 0;
  if Length(ATariffList) = 0 then
  begin
    writeln('������ ������� ����!');
    Exit;
  end;

  writeln('������ ��������� �������: ');
  VisibleIndex := 0;
  for i := 0 to High(ATariffList) do
  begin
    if not ATariffList[i].isDeleted then
    begin
      Inc(VisibleIndex);
      writeln('[', VisibleIndex, ']  ', ATariffList[i].planName);
    end;
  end;

  // �������� ���������� ������ �� ������������
  repeat
    write('������� ����� ��� ��������: ');
    readln(UserIndex);
  until (UserIndex >= 1) and (UserIndex <= VisibleIndex);

  // ������� �������� ������ � �������
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
    writeln('������ ��������!');
    Exit;
  end;

  // �������� ������ ��� ���������
  ATariffList[RealIndex].isDeleted := true;
  writeln('����� "', ATariffList[RealIndex].planName, '" �����');
end;

// [7] �������������� ������(����������� �����)
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
    writeln('������ ������� ����!');
    Exit;
  end;

  writeln('==================== ������ ��������� ������� =====================');
  for i := 0 to High(ATariffList) do
    writeln(' ', i + 1, ') ', ATariffList[i].planName);

  repeat
    isValid := true;
    write('�������� ����� ��� �������������� �������.�����: ');
    readln(inputStr);

    tarifIndex := 0;
    for tempChIndex := 1 to Length(inputStr) do
    // ������� ������� ������� � ������

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
      writeln('������: ������ ������ �� ����������');
      isValid := false;
    end;
  until isValid;

  repeat
    write('������ ����� �������� ��� ����������� �����(������� �������� ',
      ATariffList[tarifIndex].abonentPlata: 0: 2, '): ');
    readln(inputStr);
    isValid := TryStrToFloat(inputStr, newValue);
    if not isValid then
      write('������: ������� ���������� �����: ');
  until isValid;

  ATariffList[tarifIndex].abonentPlata := newValue;
  writeln('����������� ����� �������� �� ', newValue:0:2);
  readln;
end;

// [8] ����������� �������
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
    writeln('������ ������� ����!');
    Exit;
  end;

  writeln('===========������� ������ ������� �������� �� �����==========');

  writeln('������ ������ ��� �������� ������: ');
  repeat
    isValid := true;
    Write('���������� ����������� �����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    Write('������ ������ ����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    Write('������ �� ������ ����: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    Write('�������� SMS: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    Write('�������� MMS: ');
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
      writeln('������: ������� �����');
  until isValid;

  repeat
    isValid := true;
    Write('�������� ����������: ');
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
      writeln('������: ������� �����');
  until isValid;

  SetLength(tariffsNames, 0);
  SetLength(tariffsCoasts, 0);
  for i := 0 to High(ATariffList) do
  begin
    if ATariffList[i].isDeleted then
      Continue;
    SetLength(tariffsNames, Length(tariffsNames) + 1);
SetLength(tariffsCoasts, Length(tariffsCoasts) + 1);
tariffsNames[High(tariffsNames)] := ATariffList[i].planName; // <-- ����������
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

  // ���������� ������ �������
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
      // ����� �����������
      TempCost := tariffsCoasts[i];
      tariffsCoasts[i] := tariffsCoasts[minIndex];
      tariffsCoasts[minIndex] := TempCost;

      // ����� ����������
      TempNames := tariffsNames[i];
      tariffsNames[i] := tariffsNames[minIndex];
      tariffsNames[minIndex] := TempNames;
    end;
  end;

  // ����� �����������
  writeln('���������� �������:');
  writeln('================================================');
  for i := 0 to High(tariffsNames) do
    writeln('[', i + 1, '] ', tariffsNames[i], ': ', tariffsCoasts[i]:0
      :2, ' ���.');

  // ������ � ����
  AssignFile(F, AFileName);
  try
    Rewrite(F);
    writeln(F, '���������� �������:');
    for i := 0 to High(tariffsNames) do
      writeln(F, tariffsNames[i], ';', tariffsCoasts[i]:0:2);
    writeln('������ ��������� � ����: ', AFileName);
  except
    writeln('������ ������ � ����!');
  end;
  CloseFile(F);

  readln;
end;

// [10] ����� � ����������� ���������
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
    writeln('������ ��������� � ����: ', AFileName);
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
      write('������� ����� ������: ');
      readln(inputStr);
      isValid := TryStrToInt(inputStr, choice);
      if not isValid or (choice < 1) or (choice > 10) then
        writeln('������: ������� ����� �� 1 �� 10.');
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
      writeln('������� ���������� �����');
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
      writeln('������� ���������� �����'); }
    writeln;
  end;
  readln;

end.
