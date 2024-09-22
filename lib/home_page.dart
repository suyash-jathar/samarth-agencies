import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:samarth_agencies/pages/create_patient.dart';
import 'package:samarth_agencies/pages/create_test.dart';


import 'pages/create_bill.dart';
import 'pages/list_bills.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              // showTooltip: false,
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: Colors.blue[100],
              selectedHoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10)),
              // ),
              // backgroundColor: Colors.grey[200]
            ),
            title: Column(
              children: [
                // ConstrainedBox(
                //   constraints: const BoxConstraints(
                //     maxHeight: 150,
                //     maxWidth: 150,
                //   ),
                //   child: Image.asset(
                //     'assets/images/easy_sidemenu.png',
                //   ),
                // ),
                // const Divider(
                //   indent: 8.0,
                //   endIndent: 8.0,
                // ),
              ],
            ),
            footer: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Text(
                    'S S Pathology Invoice',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                ),
              ),
            ),
            items: [
              SideMenuItem(
                title: 'Create Bill',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.home),
                tooltipContent: "This is a tooltip for Create Bill item",
              ),
              SideMenuItem(
                title: 'Create Patient',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.supervisor_account),
              ),
              SideMenuItem(
                title: 'Tests',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.file_copy_rounded),
              ),
              SideMenuItem(
                title: 'List of Bills',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.download),
              ),
              SideMenuItem(
                title: 'Dashboard',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.dashboard),
              ),
              // SideMenuItem(
              //   title: 'Settings',
              //   onTap: (index, _) {
              //     sideMenu.changePage(index);
              //   },
              //   icon: const Icon(Icons.settings),
              // ),
              // const SideMenuItem(
              //   title: 'Exit',
              //   icon: Icon(Icons.exit_to_app),
              // ),
            ],
          ),
          const VerticalDivider(width: 0,),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                Container(
                  color: Colors.white,
                  child: CreateBill(),
                ),
                Container(
                  color: Colors.white,
                  child: CreatePatient()
                ),
                Container(
                  color: Colors.white,
                  child: CreateTests()
                ),
                Container(
                  color: Colors.white,
                  child: ListBill()
                ),
                Container(
                  color: Colors.white,
                  child: Center(
                    child: Text("Coming Soon -> Live Dashboard")
                  )
                ),
                // this is for SideMenuItem with builder (divider)
                const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ));
  }}