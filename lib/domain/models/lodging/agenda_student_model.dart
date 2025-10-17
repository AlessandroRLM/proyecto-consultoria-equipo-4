import 'agenda_model.dart';

/// Para separar “agendas del estudiante” a nivel de módulo sin duplicar modelos,
/// dejamos un alias de tipo. Así puedes importar este archivo en la capa UI
/// cuando trabajes específicamente con `schedule_student.json`.
typedef AgendaStudentModel = AgendaModel;
