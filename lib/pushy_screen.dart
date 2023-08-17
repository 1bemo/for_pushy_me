///экран pushy

import 'package:flutter/material.dart';
import 'dart:async';

//global packages
import 'package:pushy_flutter/pushy_flutter.dart';

///фоновый слушатель уведомлений. Принимает мапу, похожуя на json - String, dynamic
@pragma('vm:entry-point')
void _backgroundNotificationListener(Map<String, dynamic> data) {
  debugPrint('Получили данные: $data');

  // заголовок
  String title = data['title'] ?? 'Без заголовка';

  // сообщение
  String message = data['message'] ?? 'Без сообщения';

  ///-------------------- ПОКАЗАТЬ САМ ПУШ --------------------///
  // Android: Отображает системное уведомление
  // iOS: Отображает алерт диалог
  Pushy.notify(title, message, data);

  // Очистить номер значка приложения iOS - что то важное видать
  //предположительно - убирает точку с иконки об уведомлении на iOS
  Pushy.clearBadge();
}

class PushyDemo extends StatefulWidget {
  const PushyDemo({super.key});

  @override
  PushyDemoState createState() => PushyDemoState();
}

class PushyDemoState extends State<PushyDemo> {
  String _deviceToken = 'Загрузка...';

  @override
  void initState() {
    super.initState();

    //инициализируем уведомления
    initPushy();
  }

  ///ф-я инициализации уведомлений
  Future<void> initPushy() async {
    // запустить фоновый сервис pushy
    Pushy.listen();

    // установить appId аккаунта pushy.me - с чем связать или куда стучатся за регистарцией
    Pushy.setAppId('64d5ceb626fd5b0367fa51a4');

    //стучимся
    try {
      // пробуем зарегистрировать устройство в сервисе pushy. Как итог получаем токен устройства
      String deviceToken = await Pushy.register();

      debugPrint('Получили токен после регистрации: $deviceToken');

      // Тут нужно отправить этот токен к себе в 1С
      // ...

      // перерисовать интерфейс
      setState(() {
        _deviceToken = deviceToken;
      });
    } catch (e) {
      debugPrint('Ошибка в попытке Pushy.register(): $e');
    }

    ///=== независимо от удачной или неудачной рагистрации ===///
    // выключить баннеры уведомлений (для iOS 10+)
    Pushy.toggleInAppBanner(false);
    // слушаем полученные уведомления и при получении запускаем ф-ю _backgroundNotificationListener
    Pushy.setNotificationListener(_backgroundNotificationListener);
    // слушаем клики по уведомлениям и выполняем ф-ю при клике
    Pushy.setNotificationClickListener((Map<String, dynamic> data) {
      debugPrint('Кликнули по уведомлению');

      String title = data['title'] ?? 'MyApp';
      String message = data['message'] ?? 'Hello World!';

      //показать диалог с данными уведомления
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title), content: Text(message),
              actions: [
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () { Navigator.pop(context); },
                )
              ]
          );
        },
      );

      // Очистить номер значка приложения iOS - что то важное видать
      //чистим причем сразу после открытия диалога, не дожыдаясь его закрытия
      //предположительно - убирает точку с иконки об уведомлении на iOS
      Pushy.clearBadge();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сервис pushy.me'),),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///иконка
            Icon(Icons.circle_notifications_rounded,size: 90,color: Colors.grey[700],),

            const SizedBox(height: 10,),

            ///токен устройства
            Text('Токен: $_deviceToken',textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[700])
            ),
          ]
        )
      ),
    );
  }
}