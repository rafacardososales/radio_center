import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_app/model/radio.dart';
import 'package:radio_app/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:alan_voice/alan_voice.dart';




class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio>? radios;
  MyRadio? _selectedRadio;
  Color? _selectedColor;
  bool _isPlaying = false;
  final suggestions = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music",
  ];

  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadio();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.PLAYING) {
        _isPlaying = true;
      }else{
        _isPlaying = false;
      }
      setState(() {});
    });
  }


  //Key
  setupAlan(){
    AlanVoice.addButton(
        "03fda28f824be5c798e4f6f0ca07008e2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _commands(command.data));
  }


  //Aqui tratamos os comandos da AIAlan.
  //Lembrando que os commandos são previamentes escritos em um script no site da AIAlan
  _commands(Map<String,dynamic>response){
    switch(response["command"]){
      case "play":
        _playMusic(_selectedRadio!.url.toString());
        break;
      case "play_channel":
        final id = response["id"];
        _audioPlayer.pause();
        MyRadio newRadio = radios!.firstWhere((element) => element.id == id);
        radios!.remove(newRadio);
        radios!.insert(0, newRadio);
        _playMusic(newRadio.url.toString());
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio!.id;
        MyRadio newRadio;
        if(index! + 1>radios!.length){
          newRadio = radios!.firstWhere((element) => element.id == 1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);
        }else{
          newRadio = radios!.firstWhere((element) => element.id == index +1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);
        }
        _playMusic(newRadio.url.toString());
        break;

      case "prev":
        final index = _selectedRadio!.id;
        MyRadio newRadio;
        if(index! - 1 <= 0){
          newRadio = radios!.firstWhere((element) => element.id == 1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);

        }else{
          newRadio = radios!.firstWhere((element) => element.id == index - 1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);
        }
        _playMusic(newRadio.url.toString());
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }
  //Este comando e responsavel por buscar as radios.
  fetchRadio() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios![0];
    _selectedColor = Color(int.tryParse(_selectedRadio!.color.toString()) as int);
    //print(radios);
    setState(() {});
  }

  _playMusic(String url)async{
    await _audioPlayer.play(url);
    _selectedRadio = radios!.firstWhere((element) => element.url == url);
    print('radioooooooooooooo ${_selectedRadio!.name}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor ?? AIColors.primaryColor2,
          child: radios != null
          ?[
            100.heightBox,
            "ALL Channels".text.xl.white.semiBold.make().px16(),
            20.heightBox,
            ListView(
              children:
                radios!.map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(e.icon.toString()),
                  ),
                  title: "${e.name} FM".text.white.make(),
                  subtitle: e.tagline!.text.white.make(),
                )).toList(),
              shrinkWrap: true,
              padding: Vx.m0,
            )
          ].vStack(crossAlignment: CrossAxisAlignment.start)
          :const Offstage(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          VxAnimatedBox().size(context.screenWidth, context.screenHeight)
          .withGradient(LinearGradient(
            colors: [
              AIColors.primaryColor2,
              _selectedColor ?? AIColors.primaryColor1,
            ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            ),
          )
          .make(),
          [
            AppBar(
            title: "Radio Center".text.xl4.bold.white.make().shimmer(
              primaryColor: Vx.purple300,
              //primaryColor: Vx.purple300,
              secondaryColor: Colors.white
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            ).h(100.0).p16(),
            "Start with Hey Alan 👇".text.italic.semiBold.white.make(),
            10.heightBox,
            VxSwiper.builder(
              itemCount: suggestions.length,
              height: 50.0,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayAnimationDuration: 3.seconds,
              autoPlayCurve: Curves.linear,
              itemBuilder: (context, index){
                final s = suggestions[index];
                return Chip(
                      label: s.text.make(),
                      backgroundColor: Vx.randomColor,
                  );
               },
            )
          ].vStack(),
          30.heightBox,
          radios != null
              ? VxSwiper.builder(
              itemCount: radios!.length,
              aspectRatio: 1.0,
              enlargeCenterPage: true,
              onPageChanged: (index){
                _selectedRadio = radios![index];
                final colorHex = radios![index].color;
                _selectedColor = Color(int.tryParse(colorHex!) as int);
                setState(() {});
              },
              itemBuilder: (context, index){
                final rad = radios![index];
                return VxBox(
                  child: ZStack([
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: VxBox(
                        child: rad.category!.text.uppercase.white.make().px16()
                      )
                          .height(40)
                          .black
                          .alignCenter
                          .withRounded(value: 10.0)
                          .make(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VStack([
                        rad.name!.text.xl3.white.bold.make(),
                        5.heightBox,
                        rad.tagline!.text.sm.white.semiBold.make(),
                      ],
                        crossAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: [
                        const Icon(
                          CupertinoIcons.play_circle,
                          color: Colors.white,
                        ),
                        10.heightBox,
                        "Double tap to play".text.gray300.make(),
                      ].vStack()
                    )
                  ],
                  )
                )
                .clip(Clip.antiAlias)
                .bgImage(DecorationImage(
                  image: NetworkImage(rad.image!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken
                  )
                ))
                .border(color: Colors.black, width: 5.0)
                .withRounded(value: 60)
                .make()
                .onInkDoubleTap(() {
                  _playMusic(rad.url.toString());
                })
                .p16();
              }
          ).centered():const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,),
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: [
              if(_isPlaying)
                "Playing Now - ${_selectedRadio!.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                        ? CupertinoIcons.stop_circle
                        : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onTap(() {
                if(_isPlaying){
                  _audioPlayer.stop();
                }else{
                  _playMusic(_selectedRadio!.url.toString());
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
