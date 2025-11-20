import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/lodging/driven/for_persisting_reservations.dart';
import 'package:mobile/ports/lodging/drivers/for_reserving_lodging.dart';

class LodgingReserveService implements ForReservingLodging {
  final ForPersistingReservations _lodgingRepository;


  LodgingReserveService({
    ForPersistingReservations? lodgingRepository,
  }) : _lodgingRepository = lodgingRepository!;

  Campus? _campus;

  @override
  Campus? get campus => _campus;

  @override
  set campus(Campus? campus) {
    _campus = campus!;
  }

  DateTime? _initDate;

  @override
  DateTime? get initDate => _initDate;

  @override
  set initDate(DateTime? initDate) {
    _initDate = initDate!;
  }

  DateTime? _endDate;

  @override
  DateTime? get endDate => _endDate;

  @override
  set endDate(DateTime? endDate) {
    _endDate = endDate!;
  }

  @override
  Future<void> reserveLodging(DateTime initDate, DateTime endDate, Campus campus) async {
    await _lodgingRepository.saveReservation(initDate, endDate, campus);
  }

  @override
  DateTime getMinReservableDate() {
    const int cutoffWeekday = 3;
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = now.add(
      Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday),
    );
    DateTime minReservableDate;
    if (todayWeekday < cutoffWeekday) {
      minReservableDate = nextMonday;
    } else {
      minReservableDate = nextMonday.add(const Duration(days: 7));
    }
    return minReservableDate;
  }
}