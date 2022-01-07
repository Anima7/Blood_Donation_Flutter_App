import 'package:bdf/brand_colors.dart';
import 'package:bdf/tabs/hometab.dart';
import 'package:bdf/tabs/profiletab.dart';
import 'mainpage.dart';
import 'package:flutter/material.dart';

class DonorMainPage extends StatefulWidget {
  static const String id = 'donormainpage';
  _DonorMainPageState createState() => _DonorMainPageState();
}

class _DonorMainPageState extends State<DonorMainPage> with SingleTickerProviderStateMixin {

  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          MainPage(),
          HomeTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accepter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Donor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selecetdIndex,
        unselectedItemColor: BrandColors.colorIcon,
        selectedItemColor: BrandColors.colorOrange,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }


}