// bottom_sheets.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 공통 컬럼 정의
class PickerColumn<T> {
  final List<T> items;
  final int initialIndex;
  final String Function(T) label;

  PickerColumn({required this.items, required this.initialIndex, required this.label});
}

/// 공통 BottomSheet (N-컬럼 선택)
Future<List<dynamic>?> showPickerBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<PickerColumn> columns,
  String confirmText = '저장',
  double height = 394,
}) {
  final indices = <int>[for (final c in columns) (c.initialIndex.clamp(0, c.items.length - 1))];
  const double itemExtent = 44;

  return showModalBottomSheet<List<dynamic>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    height:4,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              // 부제
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              // 피커
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Row(
                  children: [
                    for (int col = 0; col < columns.length; col++)
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: indices[col]),
                          itemExtent: itemExtent,
                          magnification: 1.08,
                          squeeze: 1.1,
                          useMagnifier: true,
                          selectionOverlay: Container(
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(color: Color(0x22000000), width: 1.0),
                              ),
                            ),
                          ),
                          onSelectedItemChanged: (i) {
                            indices[col] = i;
                          },
                          children: [
                            for (final item in columns[col].items)
                              Center(
                                child: Text(
                                  columns[col].label(item),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 44),
              // 저장 버튼
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 13, 0, 13),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(child: Text(confirmText)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// --------- 4가지 시트 래퍼 ---------

/// 1) 주차 선택 (KO) : 연/월/주
Future<({int year, int month, int week})?> showWeekPickerKo(
  BuildContext context, {
  int initialYear = 2025,
  int initialMonth = 4,
  int initialWeek = 1,
  int yearStart = 2023,
  int yearEnd = 2030,
}) async {
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final months = [for (int m = 1; m <= 12; m++) m];
  // 단순화: 1~5주 (필요 시 월별 주차 계산 로직으로 교체)
  final weeks = [for (int w = 1; w <= 5; w++) w];

  final res = await showPickerBottomSheet(
    context: context,
    title: '주차 선택',
    subtitle: '조회할 연도/월/주차를 선택하세요',
    confirmText: '저장',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y년'),
      PickerColumn(items: months, initialIndex: initialMonth - 1, label: (m) => '$m월'),
      PickerColumn(items: weeks, initialIndex: initialWeek - 1, label: (w) => '$w주'),
    ],
  );
  if (res == null) return null;
  return (year: res[0] as int, month: res[1] as int, week: res[2] as int);
}

/// 2) Select Week (EN) : Y / Mon / W
Future<({int year, int month, int week})?> showWeekPickerEn(
  BuildContext context, {
  int initialYear = 2025,
  int initialMonth = 4,
  int initialWeek = 1,
  int yearStart = 2023,
  int yearEnd = 2030,
}) async {
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final weeks = [for (int w = 1; w <= 5; w++) w];

  final res = await showPickerBottomSheet(
    context: context,
    title: 'Select Week',
    subtitle: 'Select the year, month, and week to view',
    confirmText: 'Save',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y'),
      PickerColumn(
        items: List<int>.generate(12, (i) => i + 1),
        initialIndex: initialMonth - 1,
        label: (i) => months[i - 1],
      ),
      PickerColumn(items: weeks, initialIndex: initialWeek - 1, label: (w) => 'W $w'),
    ],
  );
  if (res == null) return null;
  return (year: res[0] as int, month: res[1] as int, week: res[2] as int);
}

/// 3) 연도 선택 (KO)
Future<int?> showYearPickerKo(
  BuildContext context, {
  int initialYear = 2025,
  int yearStart = 2023,
  int yearEnd = 2030,
}) async {
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final res = await showPickerBottomSheet(
    context: context,
    title: '연도 선택',
    subtitle: '조회할 연도를 선택하세요',
    confirmText: '저장',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y년'),
    ],
  );
  return res == null ? null : res.first as int;
}

/// 4) Select Year (EN)
Future<int?> showYearPickerEn(
  BuildContext context, {
  int initialYear = 2025,
  int yearStart = 2023,
  int yearEnd = 2030,
}) async {
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final res = await showPickerBottomSheet(
    context: context,
    title: 'Select Year',
    subtitle: 'Select the year to view',
    confirmText: 'Save',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y'),
    ],
  );
  return res == null ? null : res.first as int;
}

/// 5) 월 선택 (KO) : 연/월
Future<({int year, int month})?> showMonthPickerKo(
  BuildContext context, {
  int initialYear = 2025,
  int initialMonth = 4,
  int yearStart = 2020,
  int yearEnd = 2032,
}) async {
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final months = [for (int m = 1; m <= 12; m++) m];

  final res = await showPickerBottomSheet(
    context: context,
    title: '월 선택',
    subtitle: '조회할 연도와 월을 선택하세요.',
    confirmText: '선택',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y년'),
      PickerColumn(items: months, initialIndex: initialMonth - 1, label: (m) => '$m월'),
    ],
  );
  if (res == null) return null;
  return (year: res[0] as int, month: res[1] as int);
}

/// 6) Select Month (EN) : Year/Month
Future<({int year, int month})?> showMonthPickerEn(
  BuildContext context, {
  int initialYear = 2025,
  int initialMonth = 4,
  int yearStart = 2020,
  int yearEnd = 2032,
}) async {
  const monthAbbr = [
    'Jan.',
    'Feb.',
    'Mar.',
    'Apr.',
    'May',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sep.',
    'Oct.',
    'Nov.',
    'Dec.',
  ];
  final years = [for (int y = yearStart; y <= yearEnd; y++) y];
  final months = [for (int m = 1; m <= 12; m++) m];

  final res = await showPickerBottomSheet(
    context: context,
    title: 'Select Month',
    subtitle: 'Select the year and month to search.',
    confirmText: 'Select',
    columns: [
      PickerColumn(items: years, initialIndex: years.indexOf(initialYear), label: (y) => '$y'),
      PickerColumn(items: months, initialIndex: initialMonth - 1, label: (m) => monthAbbr[m - 1]),
    ],
  );
  if (res == null) return null;
  return (year: res[0] as int, month: res[1] as int);
}
