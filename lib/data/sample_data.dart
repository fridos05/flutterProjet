import 'package:edumanager/models/user.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/models/payment.dart';
import 'package:edumanager/models/notification.dart';

class SampleData {
  // Togolese Users
  static final List<User> users = [
    // Parents
    const Parent(
      id: 'parent_1',
      name: 'M. Kofi Mensah',
      email: 'kofi.mensah@gmail.com',
      phone: '+228 90 12 34 56',
      address: 'Quartier Kodjoviakopé',
      city: 'Lomé',
      avatar: 'https://pixabay.com/get/gc65d2b6be33c7288005c78ccaf397f528c896a9baec1a6cd3ff66b75932348a7b3a407eb36ee870591520e7cb3b48d46348829abd8d395786f10b18252eed310_1280.jpg',
      childrenIds: ['student_1', 'student_2'],
    ),
    
    // Teachers
    const Teacher(
      id: 'teacher_1',
      name: 'Mme Akosua Koffi',
      email: 'akosua.koffi@gmail.com',
      phone: '+228 90 23 45 67',
      address: 'Quartier Agoè-Nyivé',
      city: 'Lomé',
      avatar: 'https://pixabay.com/get/gae2e0bd823010ee3778c2a172fa5bb600a0054d6e85bc523d9da93d6749377b351a3129545a829fb5aca42f5a958979a780e3a389e9a06d8dae12fba1277199e_1280.jpg',
      subjects: ['Mathématiques', 'Sciences Physiques'],
      hourlyRate: 8000,
      experience: 8,
      qualification: 'Licence en Mathématiques',
    ),
    
    const Teacher(
      id: 'teacher_2',
      name: 'M. Edem Togo',
      email: 'edem.togo@gmail.com',
      phone: '+228 90 34 56 78',
      address: 'Quartier Bè',
      city: 'Lomé',
      avatar: 'https://pixabay.com/get/g4ee8cb7e979bf43d70d2f028c14f1295e9d1fd9d00aedc673c26110faa0984d538786aee789cabff25f39555234e3ea077b6638b4cc324828a7b7b81c82e5554_1280.jpg',
      subjects: ['Français', 'Histoire-Géo'],
      hourlyRate: 6500,
      experience: 5,
      qualification: 'Licence en Lettres Modernes',
    ),
    
    const Teacher(
      id: 'teacher_3',
      name: 'Mme Afi Ablodé',
      email: 'afi.ablode@gmail.com',
      phone: '+228 90 45 67 89',
      address: 'Quartier Tokoin',
      city: 'Lomé',
      avatar: 'https://i.pravatar.cc/150?u=afi.ablode', // Added a placeholder avatar
      subjects: ['Anglais', 'Français'],
      hourlyRate: 7000,
      experience: 6,
      qualification: 'Master en Anglais',
    ),
    
    // Students
    const Student(
      id: 'student_1',
      name: 'Ama Adjovi',
      email: 'ama.adjovi@gmail.com',
      age: 14,
      grade: '3ème',
      school: 'Collège Sainte Marie',
      city: 'Lomé',
      subjects: ['Mathématiques', 'Français', 'Anglais'],
      avatar: 'https://pixabay.com/get/g0b47df3e4e834471ed6f47a0e37c19cfbfe91ddc216bf24f140461929ffa8da71de1a1826a0a8098825e3d008f9dad48602c0d89509980286a539817f365acac_1280.jpg',
    ),
    
    const Student(
      id: 'student_2',
      name: 'Kossi Agbeko',
      email: 'kossi.agbeko@gmail.com',
      age: 16,
      grade: '2nde',
      school: 'Lycée de Lomé',
      city: 'Lomé',
      subjects: ['Sciences Physiques', 'Mathématiques'],
      avatar: 'https://pixabay.com/get/g51602ee8c78c04b8262c0926a2efec337c563eb4a4915625271f3bb7c00767ce36cede1408cfa57e06c1f05a258ba8c1281a8341d2ed0f6ffd476798851bd458_1280.jpg',
    ),
    
    // Witness
    const User(
      id: 'witness_1',
      name: 'Mme Efua Koudjo',
      email: 'efua.koudjo@gmail.com',
      role: UserRole.witness,
      phone: '+228 90 56 78 90',
      address: 'Quartier Adidogomé',
      city: 'Lomé',
      avatar: 'https://i.pravatar.cc/150?u=efua.koudjo', // Added a placeholder avatar
    ),
  ];

  // Sample courses with Togolese context
  static final List<Course> courses = [
    Course(
      id: 'course_1',
      subject: 'Mathématiques',
      teacherId: 'teacher_1',
      studentId: 'student_1',
      startTime: DateTime(2024, 12, 23, 14, 0), // Lundi 14h
      endTime: DateTime(2024, 12, 23, 15, 0),
      status: CourseStatus.scheduled,
      pricePerSession: 8000,
      location: 'Domicile - Kodjoviakopé',
    ),
    
    Course(
      id: 'course_2',
      subject: 'Français',
      teacherId: 'teacher_2',
      studentId: 'student_1',
      startTime: DateTime(2024, 12, 25, 16, 0), // Mercredi 16h
      endTime: DateTime(2024, 12, 25, 17, 0),
      status: CourseStatus.scheduled,
      pricePerSession: 6500,
      location: 'Domicile - Kodjoviakopé',
    ),
    
    Course(
      id: 'course_3',
      subject: 'Sciences Physiques',
      teacherId: 'teacher_1',
      studentId: 'student_2',
      startTime: DateTime(2024, 12, 27, 10, 0), // Vendredi 10h
      endTime: DateTime(2024, 12, 27, 11, 0),
      status: CourseStatus.scheduled,
      pricePerSession: 8000,
      location: 'Domicile - Bè',
    ),
    
    Course(
      id: 'course_4',
      subject: 'Mathématiques',
      teacherId: 'teacher_1',
      studentId: 'student_2',
      startTime: DateTime(2024, 12, 21, 15, 0), // Samedi 15h
      endTime: DateTime(2024, 12, 21, 16, 0),
      status: CourseStatus.completed,
      pricePerSession: 8000,
      location: 'Centre de cours - Tokoin',
    ),
  ];

  // Sample payments
  static final List<Payment> payments = [
    Payment(
      id: 'payment_1',
      userId: 'parent_1',
      amount: 32000, // 4 cours de maths
      dueDate: DateTime(2024, 12, 31),
      status: PaymentStatus.pending,
      description: 'Cours de Mathématiques - Décembre 2024',
    ),
    
    Payment(
      id: 'payment_2',
      userId: 'parent_1',
      amount: 26000, // 4 cours de français
      dueDate: DateTime(2024, 12, 31),
      status: PaymentStatus.pending,
      description: 'Cours de Français - Décembre 2024',
    ),
    
    Payment(
      id: 'payment_3',
      userId: 'parent_1',
      amount: 30000,
      dueDate: DateTime(2024, 11, 30),
      status: PaymentStatus.paid,
      description: 'Cours divers - Novembre 2024',
      paidDate: DateTime(2024, 11, 28),
      transactionId: 'TXN_001',
    ),
  ];

  // Sample notifications
  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'notif_1',
      title: 'Cours de Mathématiques',
      message: 'Rappel : Cours avec Mme Akosua dans 30 minutes',
      type: NotificationType.courseReminder,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      userId: 'student_1',
    ),
    
    AppNotification(
      id: 'notif_2',
      title: 'Paiement en attente',
      message: 'Facture de 58,000 FCFA à régler avant le 31 décembre',
      type: NotificationType.paymentDue,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'parent_1',
    ),
    
    AppNotification(
      id: 'notif_3',
      title: 'Cours terminé',
      message: 'Le cours de Sciences Physiques s\'est bien déroulé',
      type: NotificationType.courseCompleted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'parent_1',
      isRead: true,
    ),
    
    AppNotification(
      id: 'notif_4',
      title: 'Nouveau message',
      message: 'M. Edem a envoyé un rapport de cours',
      type: NotificationType.newMessage,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      userId: 'parent_1',
    ),
  ];

  // Statistics
  static const Map<String, dynamic> statistics = {
    'totalCourses': 18,
    'teacherAttendance': 96,
    'monthlyRevenue': 135000,
    'pendingReschedules': 2,
    'totalStudents': 2,
    'activeTeachers': 3,
    'completedCourses': 15,
    'upcomingCourses': 3,
  };

  // Togolese cities
  static const List<String> cities = [
    'Lomé',
    'Kara',
    'Sokodé',
    'Atakpamé',
    'Kpalimé',
    'Dapaong',
    'Tsévié',
    'Aného',
  ];

  // Local schools
  static const List<String> schools = [
    'Lycée de Lomé',
    'Collège Sainte Marie',
    'École Primaire Nyékonakpoé',
    'Lycée Technique de Tokoin',
    'Collège Protestant',
    'École Française de Lomé',
    'Lycée de Kara',
    'Collège Saint Joseph',
  ];
}
