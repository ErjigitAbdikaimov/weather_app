import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/constant/api.dart';
import 'package:weather_app/constant/app_colors.dart';
import 'package:weather_app/constant/app_text.dart';
import 'package:weather_app/constant/app_text_style.dart';
import 'package:weather_app/model/weather.dart';

List<String> cities = [
  'bishkek',
  'osh',
  'talas',
  'narun',
  'batken',
  'jalal-abad',
  'tokmok',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weather? weather;

  Future<void> weatherLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        // await Future.delayed(const Duration(seconds: 10));
        final res = await dio
            .get(ApiConst.getLocator(position.latitude, position.longitude));
        if (res.statusCode == 200) {
          weather = Weather(
            id: res.data['current']['weather'][0]['id'],
            main: res.data['current']['weather'][0]['main'],
            description: res.data['current']['weather'][0]['description'],
            icon: res.data['current']['weather'][0]['icon'],
            city: res.data['timezone'],
            temp: res.data['current']['temp'],
            country: '',
          );
        }
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      // await Future.delayed(const Duration(seconds: 10));
      final res = await dio
          .get(ApiConst.getLocator(position.latitude, position.longitude));
      if (res.statusCode == 200) {
        weather = Weather(
          id: res.data['current']['weather'][0]['id'],
          main: res.data['current']['weather'][0]['main'],
          description: res.data['current']['weather'][0]['description'],
          icon: res.data['current']['weather'][0]['icon'],
          city: res.data['timezone'],
          temp: res.data['current']['temp'],
          country: '',
        );
      }
      setState(() {});
    }
  }

  Future<void> weatherName([String? name]) async {
    final dio = Dio();
    // await Future.delayed(const Duration(seconds: 10));
    final res = await dio.get(ApiConst.address(name ?? 'bishkek'));

    if (res.statusCode == 200) {
      weather = Weather(
        id: res.data['weather'][0]['id'],
        main: res.data['weather'][0]['main'],
        description: res.data['weather'][0]['description'],
        icon: res.data['weather'][0]['icon'],
        city: res.data['name'],
        temp: res.data['main']['temp'],
        country: res.data['sys']['country'],
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    weatherName();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title:
              const Text(AppText.appBarTitle, style: AppTextStyles.appBarStyle),
          centerTitle: true,
        ),
        body: weather == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('weather.jpg'), fit: BoxFit.cover),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await weatherLocation();
                          },
                          iconSize: 50,
                          color: AppColors.white,
                          icon: const Icon(
                            Icons.near_me,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showBottom();
                          },
                          iconSize: 50,
                          color: AppColors.white,
                          icon: const Icon(
                            Icons.location_city,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text('${(weather!.temp - 273.15).toInt()}',
                            style: AppTextStyles.body1),
                        SizedBox(
                          height: 10,
                        ),
                        Image.network(
                          ApiConst.getIcon(weather!.icon, 4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(weather!.description.replaceAll(' ', '\n'),
                            textAlign: TextAlign.end,
                            style: AppTextStyles.bady2),
                        SizedBox(
                          width: 60,
                        )
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(weather!.city, style: AppTextStyles.city),
                      ),
                    ),
                  ],
                ),
              ));
  }

  void showBottom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 19, 15, 2),
            border: Border.all(color: AppColors.white),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          // color: Colors.black12,
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    setState(() {
                      weather = null;
                    });
                    weatherName(city);
                    Navigator.pop(context);
                  },
                  title: Text(city),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
