import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'oms_demo.dart';

void main() => runApp(const BechaKenaHubApp());

const brand = Color(0xFF625FEA);
const brandDark = Color(0xFF5146E5);
const ink = Color(0xFF192335);
const muted = Color(0xFF68778B);
const canvas = Color(0xFFF2F5FA);
const line = Color(0xFFE1E6EE);
const green = Color(0xFF18AD83);
const orange = Color(0xFFE59B13);
const red = Color(0xFFE45359);
const blue = Color(0xFF4387ED);

String _csvHeader(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');

int _csvColumn(List<String> headers, List<String> candidates) =>
    headers.indexWhere(candidates.contains);

String _csvValue(List<String> row, int index) =>
    index >= 0 && index < row.length ? row[index].trim() : '';

class BechaKenaHubApp extends StatelessWidget {
  const BechaKenaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BechaKena Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: muted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brand, width: 1.5),
          ),
        ),
      ),
      home: const HubShell(),
    );
  }
}

class _NavItem {
  const _NavItem(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

const resellerNav = <_NavItem>[
  _NavItem('home', 'Home', Icons.home_rounded),
  _NavItem('orders', 'Orders', Icons.inventory_2_rounded),
  _NavItem('wallet', 'Wallet', Icons.account_balance_wallet_rounded),
  _NavItem('withdraw', 'Withdraw', Icons.payments_rounded),
  _NavItem('catalog', 'Catalog', Icons.storefront_rounded),
];

const adminNav = <_NavItem>[
  _NavItem('adminHome', 'Home', Icons.space_dashboard_rounded),
  _NavItem('customers', 'Customers', Icons.people_alt_rounded),
  _NavItem('products', 'Products', Icons.inventory_2_rounded),
  _NavItem('batch', 'Batch', Icons.layers_rounded),
  _NavItem('settings', 'Settings', Icons.settings_rounded),
];

const adminMenu = <_NavItem>[
  _NavItem('adminHome', 'Dashboard', Icons.space_dashboard_rounded),
  _NavItem('customers', 'Customer Management', Icons.people_alt_rounded),
  _NavItem('products', 'Product Management', Icons.inventory_2_rounded),
  _NavItem('resellers', 'Reseller Management', Icons.storefront_rounded),
  _NavItem('batch', 'Batch Management', Icons.layers_rounded),
  _NavItem('withdrawals', 'Withdrawal Requests', Icons.payments_rounded),
  _NavItem('adminOrders', 'Order Management', Icons.receipt_long_rounded),
  _NavItem('disbursement', 'Disbursement', Icons.account_balance_rounded),
  _NavItem('adminWallet', 'Wallet', Icons.account_balance_wallet_rounded),
  _NavItem('adminNotifications', 'Notifications', Icons.notifications_rounded),
  _NavItem('settings', 'Settings', Icons.settings_rounded),
];

class HubShell extends StatefulWidget {
  const HubShell({super.key});

  @override
  State<HubShell> createState() => _HubShellState();
}

class _HubShellState extends State<HubShell> {
  String? _role;
  String _page = 'roles';
  String? _selectedOrderId;

  void _enter(String role) {
    setState(() {
      _role = role;
      _page = role == 'reseller' ? 'home' : 'adminHome';
    });
  }

  void _go(String page) {
    Navigator.of(context).maybePop();
    setState(() {
      if (page.startsWith('orderDetails:')) {
        _selectedOrderId = page.substring('orderDetails:'.length);
        _page = 'orderDetails';
      } else {
        _page = page;
      }
    });
  }

  void _switchRole() {
    Navigator.of(context).maybePop();
    setState(() {
      _role = _role == 'reseller' ? 'admin' : 'reseller';
      _page = _role == 'reseller' ? 'home' : 'adminHome';
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return RolePicker(onSelect: _enter);
    }

    final isReseller = _role == 'reseller';
    final nav = isReseller ? resellerNav : adminNav;
    final title = _titleFor(_page);
    final isStandalone = const {'login', 'register'}.contains(_page);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        leading: isStandalone
            ? IconButton(
                onPressed: () => _go(isReseller ? 'home' : 'adminHome'),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open navigation',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        actions: [
          if (!isStandalone) ...[
            IconButton(
              tooltip: 'Notifications',
              onPressed: () =>
                  _go(isReseller ? 'notifications' : 'adminNotifications'),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'Account and app sections',
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE9EAFE),
                child: Icon(Icons.person_rounded, size: 19, color: brand),
              ),
              onSelected: (value) {
                if (value == 'switch') {
                  _switchRole();
                } else {
                  _go(value);
                }
              },
              itemBuilder: (context) => [
                if (isReseller) ...[
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('My profile'),
                  ),
                  const PopupMenuItem(value: 'login', child: Text('Sign in')),
                  const PopupMenuItem(
                    value: 'register',
                    child: Text('Create account'),
                  ),
                ],
                const PopupMenuItem(
                  value: 'switch',
                  child: Text('Switch app section'),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      drawer: isStandalone
          ? null
          : HubDrawer(
              role: _role!,
              page: _page,
              onSelect: _go,
              onSwitch: _switchRole,
            ),
      body: _buildPage(),
      bottomNavigationBar: isStandalone
          ? null
          : NavigationBar(
              selectedIndex: _navIndex(nav, _page),
              onDestinationSelected: (index) => _go(nav[index].id),
              destinations: nav
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon, color: brand),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  int _navIndex(List<_NavItem> items, String page) {
    final index = items.indexWhere((item) => item.id == page);
    return index < 0 ? 0 : index;
  }

  String _titleFor(String page) {
    const titles = <String, String>{
      'home': 'Dashboard',
      'orders': 'Order Management',
      'wallet': 'Wallet',
      'withdraw': 'Withdraw Management',
      'catalog': 'Product Catalog',
      'orderDetails': 'Reseller Order Details',
      'notifications': 'Notifications',
      'profile': 'Reseller Profile',
      'login': 'Welcome Back',
      'register': 'Become a Reseller',
      'adminHome': 'Dashboard',
      'customers': 'Customer Management',
      'products': 'Product Management',
      'resellers': 'Reseller Management',
      'batch': 'Batch Management',
      'adminOrders': 'Order Management',
      'withdrawals': 'Withdrawal Requests',
      'disbursement': 'Disbursement',
      'adminWallet': 'Wallet',
      'adminNotifications': 'Notifications',
      'settings': 'System Settings',
    };
    return titles[page] ?? 'BechaKena Hub';
  }

  Widget _buildPage() {
    switch (_page) {
      case 'home':
        return ResellerHome(onOpen: _go);
      case 'orders':
        return ResellerOrders(onOpen: _go, onMessage: _message);
      case 'wallet':
        return const ResellerWallet();
      case 'withdraw':
        return WithdrawPage(onMessage: _message);
      case 'catalog':
        return ResellerCatalog(onOpen: _go);
      case 'orderDetails':
        return OrderDetails(orderId: _selectedOrderId, onMessage: _message);
      case 'notifications':
        return NotificationsPage(onMessage: _message);
      case 'profile':
        return ProfilePage(onOpen: _go);
      case 'login':
        return AuthPage(register: false, onMessage: _message, onOpen: _go);
      case 'register':
        return AuthPage(register: true, onMessage: _message, onOpen: _go);
      case 'adminHome':
        return AdminHome(onOpen: _go);
      case 'customers':
        return const AdminCustomers();
      case 'products':
        return const AdminProducts();
      case 'resellers':
        return const AdminResellers();
      case 'batch':
        return AdminBatch(onMessage: _message);
      case 'adminOrders':
        return AdminOrders(onMessage: _message);
      case 'withdrawals':
        return AdminWithdrawals(onMessage: _message);
      case 'disbursement':
        return AdminDisbursement(onMessage: _message);
      case 'adminWallet':
        return const AdminWallet();
      case 'adminNotifications':
        return NotificationsPage(onMessage: _message, admin: true);
      case 'settings':
        return const AdminSettings();
      default:
        return RolePicker(onSelect: _enter);
    }
  }
}

class RolePicker extends StatelessWidget {
  const RolePicker({required this.onSelect, super.key});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 38, 24, 28),
          children: [
            const SizedBox(height: 24),
            Container(
              height: 82,
              width: 82,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [brand, brandDark]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: brand.withValues(alpha: .25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BechaKena Hub',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your workspace to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 16),
            ),
            const SizedBox(height: 34),
            RoleCard(
              icon: Icons.storefront_rounded,
              title: 'Reseller',
              description: 'Browse products, manage customer orders and track your earnings.',
              onTap: () => onSelect('reseller'),
            ),
            const SizedBox(height: 16),
            RoleCard(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Administrator',
              description: 'Manage customers, products, resellers, batches and payments.',
              onTap: () => onSelect('admin'),
              dark: true,
            ),
            const SizedBox(height: 28),
            const Text(
              'Mobile demo • Sample information',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.dark = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? brand : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(21),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: .17)
                      : const Color(0xFFE9EAFE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: dark ? Colors.white : brand, size: 29),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: dark ? Colors.white : ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: dark ? Colors.white70 : muted,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: dark ? Colors.white : brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HubDrawer extends StatelessWidget {
  const HubDrawer({
    required this.role,
    required this.page,
    required this.onSelect,
    required this.onSwitch,
    super.key,
  });

  final String role;
  final String page;
  final ValueChanged<String> onSelect;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final isReseller = role == 'reseller';
    final items = isReseller
        ? <_NavItem>[
            ...resellerNav,
            const _NavItem(
              'notifications',
              'Notifications',
              Icons.notifications_rounded,
            ),
            const _NavItem('profile', 'My Profile', Icons.person_rounded),
            const _NavItem('login', 'Sign in', Icons.login_rounded),
            const _NavItem(
              'register',
              'Create account',
              Icons.person_add_alt_1_rounded,
            ),
          ]
        : adminMenu;
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [brand, brandDark]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BechaKena Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isReseller
                        ? 'Reseller workspace'
                        : 'Administrator workspace',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  for (final item in items)
                    ListTile(
                      selected: page == item.id,
                      selectedColor: brand,
                      selectedTileColor: const Color(0xFFF0F0FF),
                      leading: Icon(item.icon),
                      title: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () => onSelect(item.id),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('Switch app section'),
              onTap: onSwitch,
            ),
          ],
        ),
      ),
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({required this.children, this.padding, super.key});
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 26),
      children: children,
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({required this.child, this.padding, super.key});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.icon, super.key});
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 13),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: brand, size: 23),
            const SizedBox(width: 9),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = brand,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
        label: Text(label),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label.toLowerCase()) {
      'pending' || 'pending payment' || 'unpaid' => orange,
      'processing' => blue,
      'cancelled' || 'inactive' => red,
      'paid' || 'completed' || 'approved' || 'active' || 'delivered' => green,
      _ => brand,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.color = brand,
    this.icon,
    super.key,
  });
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Align(
              alignment: Alignment.centerRight,
              child: Icon(icon, color: color.withValues(alpha: .7), size: 20),
            ),
          Text(label, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.items, super.key});
  final List<MetricCard> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.53,
      children: items,
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {this.valueColor, super.key});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PriceStrip extends StatelessWidget {
  const PriceStrip({
    required this.wholesale,
    required this.retail,
    required this.profit,
    super.key,
  });
  final String wholesale;
  final String retail;
  final String profit;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('Wholesale', wholesale, blue),
      ('Retail', retail, ink),
      ('Profit', profit, green),
    ];
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: line),
              ),
              child: Column(
                children: [
                  Text(
                    entries[i].$1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entries[i].$2,
                    style: TextStyle(
                      color: entries[i].$3,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return ChoiceChip(
            label: Text(option),
            selected: active,
            onSelected: (_) => onSelect(option),
            backgroundColor: Colors.white,
            selectedColor: brand,
            labelStyle: TextStyle(
              color: active ? Colors.white : muted,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(color: active ? brand : line),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class ResellerHome extends StatelessWidget {
  const ResellerHome({required this.onOpen, super.key});
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    int orderCount(DemoOrderStatus status) =>
        demoOms.orders.where((order) => order.status == status).length;
    final simulated = demoOms.orders.where(
      (order) => order.paymentStatus == DemoPaymentStatus.simulated,
    );
    final paymentTotal = simulated.fold<int>(
      0,
      (total, order) => total + order.wholesalePrice,
    );
    final profitTotal = simulated.fold<int>(
      0,
      (total, order) => total + order.profit,
    );
    return PageBody(
      children: [
        const Panel(
          child: Text(
            'DEMO DATA • All records are in-memory samples. No real payments or disbursements are processed.',
            style: TextStyle(color: orange, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6764F3), Color(0xFF5146E5)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: brand.withValues(alpha: .2),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(color: Colors.white70, letterSpacing: 1.1),
              ),
              SizedBox(height: 13),
              Text(
                'Hello, Reseller!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Manage your orders and business activities easily.',
                style: TextStyle(color: Colors.white, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle('Order Overview', icon: Icons.assignment_rounded),
        MetricGrid(
          items: [
            MetricCard(label: 'Total Order', value: '${demoOms.orders.length}'),
            MetricCard(
              label: 'Pending',
              value: '${orderCount(DemoOrderStatus.pending)}',
              color: orange,
            ),
            MetricCard(
              label: 'Processing',
              value: '${orderCount(DemoOrderStatus.processing)}',
              color: blue,
            ),
            MetricCard(
              label: 'Delivered',
              value: '${orderCount(DemoOrderStatus.delivered)}',
              color: green,
            ),
            MetricCard(
              label: 'Cancelled',
              value: '${orderCount(DemoOrderStatus.cancelled)}',
              color: red,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle(
          'Payment Overview',
          icon: Icons.account_balance_wallet_rounded,
        ),
        Panel(
          child: Column(
            children: [
              KeyValueRow(
                'Demo-confirmed wholesale',
                '৳$paymentTotal (not verified)',
                valueColor: brand,
              ),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Projected demo profit',
                '৳$profitTotal',
                valueColor: green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Quick Access', icon: Icons.bolt_rounded),
        Row(
          children: [
            Expanded(
              child: _QuickLink(
                icon: Icons.inventory_2_rounded,
                label: 'My Orders',
                onTap: () => onOpen('orders'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickLink(
                icon: Icons.storefront_rounded,
                label: 'Catalog',
                onTap: () => onOpen('catalog'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickLink(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                onTap: () => onOpen('wallet'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Column(
            children: [
              Icon(icon, color: brand, size: 24),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResellerOrders extends StatefulWidget {
  const ResellerOrders({
    required this.onOpen,
    required this.onMessage,
    super.key,
  });
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onMessage;

  @override
  State<ResellerOrders> createState() => _ResellerOrdersState();
}

class _ResellerOrdersState extends State<ResellerOrders> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final orders = demoOms.orders.where((order) {
      final status = switch (order.status) {
        DemoOrderStatus.pending => 'Pending',
        DemoOrderStatus.processing => 'Processing',
        DemoOrderStatus.delivered => 'Delivered',
        DemoOrderStatus.cancelled => 'Cancelled',
      };
      return filter == 'All' || status == filter;
    }).toList();

    return PageBody(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        const Panel(
          child: Text(
            'DEMO WORKSPACE • Sample orders from all reseller accounts are visible. Demo payment confirmations are not verified transactions.',
            style: TextStyle(color: muted, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FilterChips(
            options: const [
              'All',
              'Pending',
              'Processing',
              'Delivered',
              'Cancelled',
            ],
            selected: filter,
            onSelect: (value) => setState(() => filter = value),
          ),
        ),
        const SizedBox(height: 14),
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Panel(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        color: brand,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          '#${order.id} • ${order.batchId}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusPill(order.status.name),
                    ],
                  ),
                  const SizedBox(height: 14),
                  KeyValueRow('Customer', order.customer.name),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Product', order.product.title),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Assigned reseller', order.reseller.name),
                  const Divider(height: 1, color: line),
                  KeyValueRow(
                    'Payment status',
                    order.paymentStatus == DemoPaymentStatus.simulated
                        ? 'DEMO • Not provider-verified'
                        : 'Unpaid',
                    valueColor:
                        order.paymentStatus == DemoPaymentStatus.simulated
                        ? orange
                        : red,
                  ),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Transfer number', '${order.transferNumber}'),
                  const SizedBox(height: 13),
                  PriceStrip(
                    wholesale: '৳${order.wholesalePrice}',
                    retail: '৳${order.retailPrice}',
                    profit: '৳${order.profit}',
                  ),
                  const SizedBox(height: 14),
                  if (order.status == DemoOrderStatus.pending)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              try {
                                demoOms.confirmPayment(order);
                                setState(() {});
                                widget.onMessage(
                                  'Demo confirmation recorded only; no payment provider was contacted.',
                                );
                              } on StateError catch (error) {
                                widget.onMessage(error.message);
                              }
                            },
                            child: const Text('Demo Payment & Confirm'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            try {
                              demoOms.transferOrder(order);
                              setState(() {});
                              widget.onMessage(
                                'Order transferred to ${order.reseller.name}.',
                              );
                            } on StateError catch (error) {
                              widget.onMessage(error.message);
                            }
                          },
                          child: const Text('Cancel / Transfer'),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            widget.onOpen('orderDetails:${order.id}'),
                        child: const Text('View Details'),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ResellerWallet extends StatelessWidget {
  const ResellerWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final reseller = demoOms.resellers.first;
    final entries = demoOms.walletEntries
        .where((entry) => entry.reseller == reseller)
        .toList()
        .reversed
        .toList();
    final balance = reseller.capital + reseller.profit;
    return PageBody(
      children: [
        const Panel(
          child: Text(
            'DEMO WALLET • Credits are simulated accounting entries, not withdrawable real funds.',
            style: TextStyle(color: orange, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        MetricCard(
          label: 'Capital',
          value: '৳${reseller.capital}',
          color: blue,
          icon: Icons.savings_rounded,
        ),
        const SizedBox(height: 12),
        MetricCard(
          label: 'Profit',
          value: '৳${reseller.profit}',
          color: green,
          icon: Icons.trending_up_rounded,
        ),
        const SizedBox(height: 12),
        MetricCard(
          label: 'Available Balance',
          value: '৳${demoOms.availableBalanceFor(reseller)} / Wallet ৳$balance',
          color: brandDark,
          icon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 20),
        const SectionTitle('Transaction History', icon: Icons.history_rounded),
        if (entries.isEmpty)
          const Panel(child: Text('No settlement credits yet.'))
        else
          Panel(
            child: Column(
              children: [
                for (var index = 0; index < entries.length; index++) ...[
                  if (index > 0) const Divider(color: line),
                  TransactionTile(
                    title:
                        'Demo batch settlement • Capital ৳${entries[index].capital} + Profit ৳${entries[index].profit}',
                    id: entries[index].reference,
                    amount:
                        '+৳${entries[index].capital + entries[index].profit}',
                    date: 'Order ${entries[index].orderId}',
                    status: 'Demo only',
                    positive: true,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.title,
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    this.positive = false,
    super.key,
  });
  final String title;
  final String id;
  final String amount;
  final String date;
  final String status;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: positive ? green : red,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: positive ? green : red,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text('Transaction ID  •  $id', style: const TextStyle(color: muted)),
          const SizedBox(height: 5),
          Text(date, style: const TextStyle(color: ink)),
          const SizedBox(height: 8),
          StatusPill(status),
        ],
      ),
    );
  }
}

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({required this.onMessage, super.key});
  final ValueChanged<String> onMessage;

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final amount = TextEditingController();
  final account = TextEditingController();
  String? method;

  @override
  void dispose() {
    amount.dispose();
    account.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reseller = demoOms.resellers.first;
    final available = demoOms.availableBalanceFor(reseller);
    return PageBody(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                'Withdrawal Request',
                icon: Icons.request_quote_rounded,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1FF),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: brand.withValues(alpha: .18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '৳$available',
                      style: const TextStyle(
                        color: brand,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              const FieldLabel('Withdrawal Amount'),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter withdrawal amount',
                ),
              ),
              const SizedBox(height: 15),
              const FieldLabel('Payment Method'),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(
                  hintText: 'Select payment method',
                ),
                items: const [
                  DropdownMenuItem(value: 'bKash', child: Text('bKash')),
                  DropdownMenuItem(value: 'Nagad', child: Text('Nagad')),
                  DropdownMenuItem(
                    value: 'Bank transfer',
                    child: Text('Bank transfer'),
                  ),
                ],
                onChanged: (value) => setState(() => method = value),
              ),
              const SizedBox(height: 15),
              const FieldLabel('Account Number'),
              TextField(
                controller: account,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter account number',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Submit Withdrawal Request',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    final requestedAmount = int.tryParse(amount.text.trim());
                    if (requestedAmount == null ||
                        account.text.trim().isEmpty ||
                        method == null) {
                      widget.onMessage(
                        'Complete the amount, payment method and account number.',
                      );
                      return;
                    }
                    try {
                      demoOms.requestWithdrawal(
                        reseller: reseller,
                        amount: requestedAmount,
                        method: method!,
                        account: account.text.trim(),
                      );
                      setState(() {});
                      widget.onMessage(
                        'Demo withdrawal request recorded. No disbursement was made.',
                      );
                      amount.clear();
                      account.clear();
                    } on StateError catch (error) {
                      widget.onMessage(error.message);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle(
          'Withdrawal Request List',
          icon: Icons.history_rounded,
        ),
        if (demoOms.withdrawals
            .where((request) => request.reseller == reseller)
            .isEmpty)
          const Panel(child: Text('No withdrawal requests yet.'))
        else
          for (final request in demoOms.withdrawals.where(
            (request) => request.reseller == reseller,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                child: Column(
                  children: [
                    KeyValueRow(request.id, '৳${request.amount}'),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Method', request.method),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Status', request.status.name),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ResellerCatalog extends StatefulWidget {
  const ResellerCatalog({required this.onOpen, super.key});
  final ValueChanged<String> onOpen;

  @override
  State<ResellerCatalog> createState() => _ResellerCatalogState();
}

class _ResellerCatalogState extends State<ResellerCatalog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = demoOms.products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Search items...',
            prefixIcon: Icon(Icons.search_rounded, color: muted),
          ),
        ),
        const SizedBox(height: 17),
        for (final product in filtered) ...[
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: brand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.description,
                  style: const TextStyle(color: muted, height: 1.5),
                ),
                const SizedBox(height: 14),
                PriceStrip(
                  wholesale: '৳${product.wholesalePrice}',
                  retail:
                      '৳${product.retailPrice(demoOms.settings.profitRate)}',
                  profit:
                      '৳${product.retailPrice(demoOms.settings.profitRate) - product.wholesalePrice}',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'View Details',
                    icon: Icons.visibility_rounded,
                    onPressed: () => widget.onOpen('orderDetails'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class OrderDetails extends StatelessWidget {
  const OrderDetails({
    required this.orderId,
    required this.onMessage,
    super.key,
  });
  final String? orderId;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    final order =
        demoOms.orderById(orderId) ??
        (demoOms.orders.isEmpty ? null : demoOms.orders.first);
    if (order == null) {
      return const PageBody(
        children: [Panel(child: Text('No order is available.'))],
      );
    }
    return Column(
      children: [
        Expanded(
          child: PageBody(
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [brand, brandDark]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: brand.withValues(alpha: .19),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RESELLER ORDER ID',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '#${order.id}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Batch ${order.batchId}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StatusPill(order.status.name),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'Customer Details',
                      icon: Icons.person_rounded,
                    ),
                    KeyValueRow('Name', order.customer.name),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Mobile Number', order.customer.mobile),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Address', order.customer.address),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Reseller', order.reseller.name),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Transfer number', '${order.transferNumber}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'Product Details',
                      icon: Icons.inventory_2_rounded,
                    ),
                    KeyValueRow('Category', order.product.category),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Title', order.product.title),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Wholesale Price', '৳${order.wholesalePrice}'),
                    const Divider(height: 1, color: line),
                    KeyValueRow('Retail Price', '৳${order.retailPrice}'),
                    KeyValueRow(
                      'Your Profit',
                      '৳${order.profit}',
                      valueColor: green,
                    ),
                    const Divider(height: 1, color: line),
                    KeyValueRow(
                      'Payment status',
                      order.paymentStatus == DemoPaymentStatus.simulated
                          ? 'DEMO • Not provider-verified'
                          : 'Unpaid',
                      valueColor: orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: order.status == DemoOrderStatus.pending
                        ? () {
                            try {
                              demoOms.transferOrder(order);
                              onMessage(
                                'Order transferred to ${order.reseller.name}; transfer ${order.transferNumber}.',
                              );
                            } on StateError catch (error) {
                              onMessage(error.message);
                            }
                          }
                        : null,
                    child: const Text('Cancel / Transfer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Demo Pay & Confirm',
                    icon: Icons.check_rounded,
                    onPressed: order.status == DemoOrderStatus.pending
                        ? () {
                            try {
                              demoOms.confirmPayment(order);
                              onMessage(
                                'Demo confirmation recorded only; no payment provider was contacted.',
                              );
                            } on StateError catch (error) {
                              onMessage(error.message);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    required this.onMessage,
    this.admin = false,
    super.key,
  });
  final ValueChanged<String> onMessage;
  final bool admin;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'All';
  final read = <int>{2, 3, 4};

  @override
  Widget build(BuildContext context) {
    final entries = demoOms.auditLog
        .map(
          (message) => (
            widget.admin ? 'Admin activity' : 'Demo activity',
            message,
            'This session',
            Icons.notifications_active_rounded,
          ),
        )
        .toList();
    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: FilterChips(
                options: const ['All', 'Unread', 'Read'],
                selected: filter,
                onSelect: (value) => setState(() => filter = value),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(
                  () => read.addAll(List.generate(entries.length, (i) => i)),
                );
                widget.onMessage('All notifications marked as read.');
              },
              child: const Text('Mark all read'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < entries.length; i++)
          if (filter == 'All' ||
              (filter == 'Unread' && !read.contains(i)) ||
              (filter == 'Read' && read.contains(i)))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => read.add(i)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: line),
                      color: read.contains(i)
                          ? Colors.white
                          : const Color(0xFFF9F8FF),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EAFE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(entries[i].$4, color: brand),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entries[i].$1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    entries[i].$3,
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entries[i].$2,
                                style: const TextStyle(
                                  color: muted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!read.contains(i)) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, color: brand, size: 11),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.onOpen, super.key});
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        Panel(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 112,
                height: 112,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [brand, brandDark]),
                ),
                child: const Text(
                  'R',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 45,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Reseller Name',
                style: TextStyle(
                  color: ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Reseller ID: RSL-10001',
                style: TextStyle(color: muted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const StatusPill('Active'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              KeyValueRow('Full Name', 'Reseller Name'),
              Divider(height: 1, color: line),
              KeyValueRow('Mobile Number', '01*********'),
              Divider(height: 1, color: line),
              KeyValueRow('Email Address', 'reseller@example.com'),
              Divider(height: 1, color: line),
              KeyValueRow('Account Status', 'Active', valueColor: green),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_rounded, color: brand),
                title: const Text('Settings'),
                subtitle: const Text('Manage your account settings'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onOpen('login'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: brand),
                title: const Text('Share Platform'),
                subtitle: const Text('Share this application with others'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.register,
    required this.onMessage,
    required this.onOpen,
    super.key,
  });
  final bool register;
  final ValueChanged<String> onMessage;
  final ValueChanged<String> onOpen;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool obscure = true;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    final register = widget.register;
    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const SizedBox(height: 8),
        Container(
          width: 82,
          height: 82,
          margin: const EdgeInsets.symmetric(horizontal: 115),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [brand, brandDark]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            register ? Icons.person_add_alt_1 : Icons.login_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          register ? 'Become a Reseller' : 'Welcome Back',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          register
              ? 'Join our platform and start your business today'
              : 'Login to your reseller account',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 15),
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                register ? 'Reseller Registration' : 'Reseller Login',
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              if (register) ...[
                const FieldLabel('FULL NAME'),
                const TextField(
                  decoration: InputDecoration(hintText: 'Enter your full name'),
                ),
                const SizedBox(height: 14),
              ],
              const FieldLabel('MOBILE NUMBER'),
              const TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: 'Enter mobile number'),
              ),
              if (register) ...[
                const SizedBox(height: 14),
                const FieldLabel('EMAIL ADDRESS (Optional)'),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const FieldLabel('PASSWORD'),
              TextField(
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: register ? 'Create a password' : 'Enter password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              if (register) ...[
                const SizedBox(height: 14),
                const FieldLabel('CONFIRM PASSWORD'),
                TextField(
                  obscureText: obscure,
                  decoration: const InputDecoration(
                    hintText: 'Confirm your password',
                  ),
                ),
                CheckboxListTile(
                  value: agree,
                  onChanged: (value) => setState(() => agree = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to the Terms & Conditions and Privacy Policy.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => widget.onMessage(
                      'Contact support to reset your password.',
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: register ? 'Create Reseller Account' : 'Login',
                  icon: register ? Icons.person_add_alt_1 : Icons.login_rounded,
                  onPressed: () {
                    if (register && !agree) {
                      widget.onMessage(
                        'Please agree to the terms to continue.',
                      );
                    } else {
                      widget.onMessage(
                        register
                            ? 'Registration form is ready to connect.'
                            : 'Login form is ready to connect.',
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () =>
                      widget.onOpen(register ? 'login' : 'register'),
                  child: Text(
                    register
                        ? 'Already have an account? Login'
                        : "Don't have an account? Create Reseller Account",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminHome extends StatelessWidget {
  const AdminHome({required this.onOpen, super.key});
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    int orderCount(DemoOrderStatus status) =>
        demoOms.orders.where((order) => order.status == status).length;
    int withdrawalCount(DemoWithdrawalStatus status) =>
        demoOms.withdrawals.where((request) => request.status == status).length;
    return PageBody(
      children: [
        const Panel(
          child: Text(
            'DEMO DATA • All records are in-memory samples. No real payments or disbursements are processed.',
            style: TextStyle(color: orange, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [brand, brandDark]),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to BechaKena Hub 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Manage your complete Order Management System from one place.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Platform Overview', icon: Icons.analytics_rounded),
        MetricGrid(
          items: [
            MetricCard(
              label: 'Customers',
              value: '${demoOms.customers.length}',
            ),
            MetricCard(
              label: 'Products',
              value: '${demoOms.products.length}',
              color: blue,
            ),
            MetricCard(
              label: 'Active resellers',
              value: '${demoOms.activeResellers.length}',
              color: green,
            ),
            MetricCard(
              label: 'Current batch',
              value: demoOms.currentBatchId,
              color: orange,
            ),
            MetricCard(
              label: 'Total Orders',
              value: '${demoOms.orders.length}',
            ),
            MetricCard(
              label: 'Pending',
              value: '${orderCount(DemoOrderStatus.pending)}',
              color: orange,
            ),
            MetricCard(
              label: 'Processing',
              value: '${orderCount(DemoOrderStatus.processing)}',
              color: blue,
            ),
            MetricCard(
              label: 'Delivered',
              value: '${orderCount(DemoOrderStatus.delivered)}',
              color: green,
            ),
            MetricCard(
              label: 'Cancelled',
              value: '${orderCount(DemoOrderStatus.cancelled)}',
              color: red,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle('Withdrawal Overview', icon: Icons.payments_rounded),
        Panel(
          child: Column(
            children: [
              KeyValueRow(
                'Pending',
                '${withdrawalCount(DemoWithdrawalStatus.pending)}',
                valueColor: orange,
              ),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Processing',
                '${withdrawalCount(DemoWithdrawalStatus.processing)}',
                valueColor: blue,
              ),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Approved',
                '${withdrawalCount(DemoWithdrawalStatus.approved)}',
                valueColor: green,
              ),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Cancelled',
                '${withdrawalCount(DemoWithdrawalStatus.cancelled)}',
                valueColor: red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle('Quick Actions', icon: Icons.bolt_rounded),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            ActionChip(
              avatar: const Icon(Icons.person_add_alt_1, color: brand),
              label: const Text('Add Customer'),
              onPressed: () => onOpen('customers'),
            ),
            ActionChip(
              avatar: const Icon(Icons.add_box_rounded, color: brand),
              label: const Text('Add Product'),
              onPressed: () => onOpen('products'),
            ),
            ActionChip(
              avatar: const Icon(Icons.account_balance_rounded, color: brand),
              label: const Text('Disbursement'),
              onPressed: () => onOpen('disbursement'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle(
          'Recent Orders • Demo',
          icon: Icons.receipt_long_rounded,
        ),
        Panel(
          child: Column(
            children: demoOms.orders.reversed.take(3).map((order) {
              return KeyValueRow(
                '#${order.id} • ${order.reseller.name}',
                '৳${order.wholesalePrice} • ${order.paymentStatus == DemoPaymentStatus.simulated ? 'Not verified' : 'Unpaid'}',
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class AdminCustomers extends StatefulWidget {
  const AdminCustomers({super.key});

  @override
  State<AdminCustomers> createState() => _AdminCustomersState();
}

class _AdminCustomersState extends State<AdminCustomers> {
  String query = '';
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  void _addCustomer() {
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and mobile number are required.')),
      );
      return;
    }
    if (demoOms.customers.any(
      (customer) => customer.mobile == phone.text.trim(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That mobile number already exists.')),
      );
      return;
    }
    setState(
      () => demoOms.customers.add(
        DemoCustomer(
          name.text.trim(),
          phone.text.trim(),
          address.text.trim().isEmpty ? '—' : address.text.trim(),
        ),
      ),
    );
    name.clear();
    phone.clear();
    address.clear();
  }

  Future<void> _editCustomer(DemoCustomer customer) async {
    final editName = TextEditingController(text: customer.name);
    final editPhone = TextEditingController(text: customer.mobile);
    final editAddress = TextEditingController(text: customer.address);
    try {
      final updated = await showDialog<DemoCustomer>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editName,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editPhone,
                decoration: const InputDecoration(labelText: 'Mobile number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editAddress,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (editName.text.trim().isEmpty ||
                    editPhone.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(
                  context,
                  DemoCustomer(
                    editName.text.trim(),
                    editPhone.text.trim(),
                    editAddress.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (!mounted || updated == null) return;
      if (demoOms.customers.any(
        (item) => item != customer && item.mobile == updated.mobile,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That mobile number already exists.')),
        );
        return;
      }
      final index = demoOms.customers.indexOf(customer);
      if (index >= 0) {
        setState(() => demoOms.customers[index] = updated);
      }
    } finally {
      editName.dispose();
      editPhone.dispose();
      editAddress.dispose();
    }
  }

  Future<void> _importCustomers() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final rows = parseCsvRows(utf8.decode(bytes));
      if (rows.isEmpty) {
        throw const FormatException('The selected CSV file is empty.');
      }
      final header = rows.first.map(_csvHeader).toList();
      final nameIndex = _csvColumn(header, const ['name', 'customer_name']);
      final mobileIndex = _csvColumn(header, const [
        'mobile',
        'mobile_number',
        'phone',
      ]);
      final addressIndex = _csvColumn(header, const ['address']);
      if (nameIndex < 0 || mobileIndex < 0) {
        throw const FormatException(
          'Customer CSV must include name and mobile_number columns.',
        );
      }
      var imported = 0;
      var skipped = 0;
      final mobileNumbers = demoOms.customers
          .map((customer) => customer.mobile)
          .toSet();
      final newCustomers = <DemoCustomer>[];
      for (final columns in rows.skip(1)) {
        final rowName = _csvValue(columns, nameIndex);
        final mobile = _csvValue(columns, mobileIndex);
        if (rowName.isEmpty || mobile.isEmpty || !mobileNumbers.add(mobile)) {
          skipped++;
          continue;
        }
        newCustomers.add(
          DemoCustomer(
            rowName,
            mobile,
            _csvValue(columns, addressIndex).isEmpty
                ? '—'
                : _csvValue(columns, addressIndex),
          ),
        );
        imported++;
      }
      if (newCustomers.isNotEmpty) {
        setState(() => demoOms.customers.addAll(newCustomers));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported $imported customer(s) from ${file.name}; skipped $skipped invalid or duplicate row(s).',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer CSV import failed: ${error.message}'),
          ),
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Customer CSV import failed: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = demoOms.customers
        .where(
          (customer) => [
            customer.name,
            customer.mobile,
            customer.address,
          ].any((value) => value.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
    return PageBody(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Add Customer', icon: Icons.person_add_alt_1),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Customer name',
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '01XXXXXXXXX',
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: address,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Customer address',
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Add Customer',
                icon: Icons.add_rounded,
                onPressed: _addCustomer,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _importCustomers,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Select customer CSV to bulk upload'),
              ),
              const SizedBox(height: 6),
              const Text(
                'CSV columns: name,mobile_number,address • Phone numbers are imported as text, preserving leading zeros.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const SectionTitle('Customer List'),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search customer...',
          ),
        ),
        const SizedBox(height: 12),
        for (final customer in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit customer',
                        onPressed: () => _editCustomer(customer),
                        icon: const Icon(Icons.edit_rounded, color: brand),
                      ),
                      IconButton(
                        tooltip: 'Delete customer',
                        onPressed: () {
                          setState(() => demoOms.customers.remove(customer));
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  KeyValueRow('Mobile Number', customer.mobile),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Address', customer.address),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  final title = TextEditingController();
  final description = TextEditingController();
  final wholesaleController = TextEditingController();
  String? wholesale;
  String category = 'Electronics';
  String query = '';

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    wholesaleController.dispose();
    super.dispose();
  }

  Future<void> _importProducts() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final rows = parseCsvRows(utf8.decode(bytes));
      if (rows.isEmpty) {
        throw const FormatException('The selected CSV file is empty.');
      }
      final headers = rows.first.map(_csvHeader).toList();
      final categoryIndex = _csvColumn(headers, const ['category']);
      final titleIndex = _csvColumn(headers, const ['title', 'product_title']);
      final descriptionIndex = _csvColumn(headers, const [
        'description',
        'details',
      ]);
      final wholesaleIndex = _csvColumn(headers, const [
        'wholesale_price',
        'wholesale',
        'price',
      ]);
      if (categoryIndex < 0 || titleIndex < 0 || wholesaleIndex < 0) {
        throw const FormatException(
          'Product CSV must include category, title, and wholesale_price columns.',
        );
      }
      final knownTitles = demoOms.products
          .map((product) => product.title.toLowerCase())
          .toSet();
      final imported = <DemoProduct>[];
      var skipped = 0;
      for (final row in rows.skip(1)) {
        final productCategory = _csvValue(row, categoryIndex);
        final productTitle = _csvValue(row, titleIndex);
        final rawPrice = _csvValue(row, wholesaleIndex);
        final wholesalePrice = int.tryParse(
          rawPrice.replaceAll(RegExp(r'^[৳$]\s*'), '').replaceAll(',', ''),
        );
        if (productCategory.isEmpty ||
            productTitle.isEmpty ||
            wholesalePrice == null ||
            wholesalePrice <= 0 ||
            wholesalePrice % 50 != 0 ||
            !knownTitles.add(productTitle.toLowerCase())) {
          skipped++;
          continue;
        }
        imported.add(
          DemoProduct(
            title: productTitle,
            category: productCategory,
            description: _csvValue(row, descriptionIndex),
            wholesalePrice: wholesalePrice,
          ),
        );
      }
      if (imported.isNotEmpty) {
        setState(() => demoOms.products.addAll(imported));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${imported.length} product(s) from ${file.name}; skipped $skipped invalid or duplicate row(s). Retail prices use the current ${demoOms.settings.profitRate}% rate.',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product CSV import failed: ${error.message}'),
          ),
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product CSV import failed: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = demoOms.products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final wholesalePrice = int.tryParse(wholesale ?? '');
    final retail = wholesalePrice == null
        ? null
        : (wholesalePrice * (1 + demoOms.settings.profitRate / 100)).round();
    final categories = <String>{
      'Electronics',
      'Fashion',
      'Home',
      'Other',
      ...demoOms.products.map((product) => product.category),
      category,
    }.toList()..sort();
    return PageBody(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Add Product', icon: Icons.add_box_rounded),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Product title',
                ),
              ),
              const SizedBox(height: 11),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Product Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: [
                  for (final value in categories)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) =>
                    setState(() => category = value ?? 'Electronics'),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: wholesaleController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Wholesale Price',
                  hintText: 'Enter an amount in ৳50 multiples',
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
                onChanged: (value) => setState(() => wholesale = value),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Product description',
                ),
              ),
              const SizedBox(height: 11),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'System Profit Rate',
                ),
                child: Text('${demoOms.settings.profitRate}%'),
              ),
              const SizedBox(height: 11),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Retail Price'),
                child: Text(retail == null ? 'Auto calculated' : '৳$retail'),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Add Product',
                icon: Icons.add_rounded,
                onPressed: () {
                  if (title.text.trim().isEmpty ||
                      wholesalePrice == null ||
                      wholesalePrice <= 0 ||
                      wholesalePrice % 50 != 0 ||
                      retail == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a title and a valid wholesale price in ৳50 multiples.',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(
                    () => demoOms.products.add(
                      DemoProduct(
                        title: title.text.trim(),
                        category: category,
                        description: description.text.trim(),
                        wholesalePrice: wholesalePrice,
                      ),
                    ),
                  );
                  title.clear();
                  description.clear();
                  wholesaleController.clear();
                  wholesale = null;
                  category = 'Electronics';
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _importProducts,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Select product CSV to bulk upload'),
              ),
              const SizedBox(height: 7),
              const Text(
                'CSV columns: category,title,description,wholesale_price • Price must be a ৳50 multiple; retail is calculated automatically.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const SectionTitle('Product List'),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search product...',
          ),
        ),
        const SizedBox(height: 12),
        for (final product in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.category} • ${product.description}',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 10),
                  KeyValueRow('Wholesale Price', '৳${product.wholesalePrice}'),
                  const Divider(height: 1, color: line),
                  KeyValueRow(
                    'Retail Price',
                    '৳${product.retailPrice(demoOms.settings.profitRate)}',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AdminResellers extends StatefulWidget {
  const AdminResellers({super.key});

  @override
  State<AdminResellers> createState() => _AdminResellersState();
}

class _AdminResellersState extends State<AdminResellers> {
  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const SectionTitle(
          'Reseller Management',
          icon: Icons.storefront_rounded,
        ),
        for (final reseller in demoOms.resellers) ...[
          ResellerAdminCard(
            name: reseller.name,
            mobile: reseller.mobile,
            email: reseller.email,
            orders: demoOms.orders
                .where((order) => order.reseller == reseller)
                .length
                .toString(),
            wallet: '৳${reseller.capital + reseller.profit}',
            status: reseller.active ? 'Active' : 'Inactive',
            active: reseller.active,
            onActiveChanged: (value) => setState(() {
              reseller.active = value;
              demoOms.auditLog.insert(
                0,
                '${reseller.name} ${value ? 'activated' : 'deactivated'} in demo.',
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class ResellerAdminCard extends StatelessWidget {
  const ResellerAdminCard({
    required this.name,
    required this.mobile,
    required this.email,
    required this.orders,
    required this.wallet,
    required this.status,
    this.active = true,
    this.onActiveChanged,
    super.key,
  });
  final String name;
  final String mobile;
  final String email;
  final String orders;
  final String wallet;
  final String status;
  final bool active;
  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusPill(status),
            ],
          ),
          const SizedBox(height: 8),
          KeyValueRow('Mobile', mobile),
          const Divider(height: 1, color: line),
          KeyValueRow('Email', email),
          const Divider(height: 1, color: line),
          KeyValueRow('Orders', orders),
          const Divider(height: 1, color: line),
          KeyValueRow('Wallet', wallet),
          if (onActiveChanged != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(active ? 'Reseller active' : 'Reseller inactive'),
              value: active,
              activeThumbColor: brand,
              onChanged: onActiveChanged,
            ),
        ],
      ),
    );
  }
}

class AdminOrders extends StatefulWidget {
  const AdminOrders({required this.onMessage, super.key});
  final ValueChanged<String> onMessage;

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  String query = '';
  String filter = 'All';

  String _label(DemoOrderStatus status) => switch (status) {
    DemoOrderStatus.pending => 'Pending',
    DemoOrderStatus.processing => 'Processing',
    DemoOrderStatus.delivered => 'Delivered',
    DemoOrderStatus.cancelled => 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final orders = demoOms.orders.where((order) {
      final matchesStatus = filter == 'All' || _label(order.status) == filter;
      final searchText = [
        order.id,
        order.batchId,
        order.customer.name,
        order.product.title,
        order.reseller.name,
      ].join(' ').toLowerCase();
      return matchesStatus && searchText.contains(query.toLowerCase());
    }).toList();
    return PageBody(
      children: [
        const Panel(
          child: Text(
            'DEMO ORDERS • Payment status reflects simulated confirmation only; verify real provider transactions on a secured backend.',
            style: TextStyle(color: orange, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => query = value.trim()),
          decoration: const InputDecoration(
            hintText: 'Search order, customer, product, reseller...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        FilterChips(
          options: const [
            'All',
            'Pending',
            'Processing',
            'Delivered',
            'Cancelled',
          ],
          selected: filter,
          onSelect: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const Panel(child: Text('No orders match this filter.')),
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${order.id} • ${order.batchId}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusPill(_label(order.status)),
                    ],
                  ),
                  const Divider(height: 18, color: line),
                  KeyValueRow('Customer', order.customer.name),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Product', order.product.title),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Wholesale', '৳${order.wholesalePrice}'),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Retail', '৳${order.retailPrice}'),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Reseller', order.reseller.name),
                  const Divider(height: 1, color: line),
                  KeyValueRow(
                    'Payment status',
                    order.paymentStatus == DemoPaymentStatus.simulated
                        ? 'DEMO • Not verified'
                        : 'Unpaid',
                    valueColor: orange,
                  ),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Transfer number', '${order.transferNumber}'),
                  if (order.status == DemoOrderStatus.pending) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        try {
                          demoOms.transferOrder(order);
                          setState(() {});
                          widget.onMessage(
                            '${order.id} transferred to ${order.reseller.name}.',
                          );
                        } on StateError catch (error) {
                          widget.onMessage(error.message);
                        }
                      },
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Transfer to active reseller'),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AdminBatch extends StatefulWidget {
  const AdminBatch({required this.onMessage, super.key});
  final ValueChanged<String> onMessage;

  @override
  State<AdminBatch> createState() => _AdminBatchState();
}

class _AdminBatchState extends State<AdminBatch> {
  @override
  Widget build(BuildContext context) {
    final division = demoOms.currentDivision;
    final batchOrders = demoOms.orders
        .where((order) => order.batchId == demoOms.currentBatchId)
        .toList();
    final progress = demoOms.currentBatchTarget == 0
        ? 0.0
        : demoOms.batchPaidTotal / demoOms.currentBatchTarget;
    final nextTarget =
        (demoOms.currentBatchTarget * (100 + demoOms.settings.growthRate) / 100)
            .round();
    return PageBody(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Batch ${demoOms.currentBatchId}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusPill(
                    demoOms.canSettleCurrentBatch
                        ? 'Target reached'
                        : 'Processing',
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'Paid: ৳${demoOms.batchPaidTotal} / ৳${demoOms.currentBatchTarget}',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                color: green,
                backgroundColor: canvas,
              ),
              const SizedBox(height: 14),
              const Text(
                'DEMO WORKSPACE • Confirmations and wallet credits below are simulated only; no payment provider or bank was contacted.',
                style: TextStyle(color: orange, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            children: [
              KeyValueRow('Batch target', '৳${demoOms.currentBatchTarget}'),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Division',
                division.map((amount) => '৳$amount').join(' + '),
              ),
              const Divider(height: 1, color: line),
              KeyValueRow('Growth rate', '${demoOms.settings.growthRate}%'),
              const Divider(height: 1, color: line),
              KeyValueRow('Next batch target', '৳$nextTarget'),
              const Divider(height: 1, color: line),
              KeyValueRow('Cycle', '${demoOms.settings.cycleHours} Hours'),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Transfer period',
                '${demoOms.settings.transferHours} Hours',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle('Division & Assignment'),
        if (division.isEmpty)
          const Panel(
            child: Text(
              'No exact division is available. Add compatible products or update the batch target.',
              style: TextStyle(color: red),
            ),
          )
        else
          for (var index = 0; index < division.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                child: Column(
                  children: [
                    KeyValueRow(
                      'Order • Wholesale',
                      '${index < batchOrders.length ? batchOrders[index].id : '—'} • ৳${division[index]}',
                    ),
                    if (index < batchOrders.length) ...[
                      const Divider(height: 1, color: line),
                      KeyValueRow('Customer', batchOrders[index].customer.name),
                      const Divider(height: 1, color: line),
                      KeyValueRow('Product', batchOrders[index].product.title),
                      const Divider(height: 1, color: line),
                      KeyValueRow('Reseller', batchOrders[index].reseller.name),
                      const Divider(height: 1, color: line),
                      KeyValueRow(
                        'Transfer number',
                        '${batchOrders[index].transferNumber}',
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            batchOrders[index].paymentStatus ==
                                    DemoPaymentStatus.simulated
                                ? 'DEMO • Not verified'
                                : 'Unpaid',
                            style: const TextStyle(
                              color: orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          StatusPill(batchOrders[index].status.name),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Settle full batch & create next',
          icon: Icons.task_alt_rounded,
          color: demoOms.canSettleCurrentBatch ? green : muted,
          onPressed: demoOms.canSettleCurrentBatch
              ? () {
                  try {
                    demoOms.settleCurrentBatch();
                    setState(() {});
                    widget.onMessage(
                      'Demo batch settled and wallet credited. No real funds were moved.',
                    );
                  } on StateError catch (error) {
                    widget.onMessage(error.message);
                  }
                }
              : () => widget.onMessage(
                  'Partial settlement is disabled. Confirm the full batch target first.',
                ),
        ),
      ],
    );
  }
}

class AdminWithdrawals extends StatefulWidget {
  const AdminWithdrawals({required this.onMessage, super.key});
  final ValueChanged<String> onMessage;

  @override
  State<AdminWithdrawals> createState() => _AdminWithdrawalsState();
}

class _AdminWithdrawalsState extends State<AdminWithdrawals> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = demoOms.withdrawals.where((request) {
      final status = switch (request.status) {
        DemoWithdrawalStatus.pending => 'Pending',
        DemoWithdrawalStatus.processing => 'Processing',
        DemoWithdrawalStatus.approved => 'Approved',
        DemoWithdrawalStatus.cancelled => 'Cancelled',
      };
      return filter == 'All' || status == filter;
    }).toList();
    return PageBody(
      children: [
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Move Pending to Processing',
            icon: Icons.forward_rounded,
            color: orange,
            onPressed: () {
              final pending = demoOms.withdrawals
                  .where((item) => item.status == DemoWithdrawalStatus.pending)
                  .length;
              demoOms.movePendingWithdrawalsToProcessing();
              setState(() {});
              widget.onMessage(
                pending == 0
                    ? 'There are no pending requests.'
                    : '$pending demo request(s) moved to processing.',
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        FilterChips(
          options: const [
            'All',
            'Pending',
            'Processing',
            'Approved',
            'Cancelled',
          ],
          selected: filter,
          onSelect: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 13),
        if (filtered.isEmpty)
          const Panel(child: Text('No withdrawal requests match this filter.')),
        for (final request in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.id,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusPill(request.status.name),
                    ],
                  ),
                  KeyValueRow('Reseller', request.reseller.name),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Amount', '৳${request.amount}'),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Method', request.method),
                  const Divider(height: 1, color: line),
                  KeyValueRow('Account', request.account),
                  if (request.transactionReference != null)
                    KeyValueRow(
                      'Transaction reference',
                      request.transactionReference!,
                    ),
                  const SizedBox(height: 9),
                  OutlinedButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(request.id),
                        content: Text(
                          'DEMO ONLY • ${request.reseller.name} • ৳${request.amount} via ${request.method}. No payment provider was contacted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          if (request.status == DemoWithdrawalStatus.pending)
                            FilledButton(
                              onPressed: () {
                                demoOms.moveWithdrawalToProcessing(request);
                                Navigator.pop(context);
                                setState(() {});
                                widget.onMessage(
                                  '${request.id} moved to demo processing.',
                                );
                              },
                              child: const Text('Move to Processing'),
                            ),
                          if (request.status ==
                              DemoWithdrawalStatus.processing) ...[
                            TextButton(
                              onPressed: () {
                                demoOms.applyDemoDisbursementResult(
                                  request,
                                  approved: false,
                                );
                                Navigator.pop(context);
                                setState(() {});
                                widget.onMessage(
                                  'Demo cancellation result recorded; no disbursement was made.',
                                );
                              },
                              child: const Text('Demo Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                demoOms.applyDemoDisbursementResult(
                                  request,
                                  approved: true,
                                );
                                Navigator.pop(context);
                                setState(() {});
                                widget.onMessage(
                                  'Demo approval recorded only; no provider transaction occurred.',
                                );
                              },
                              child: const Text('Demo Approve'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    child: Text(
                      request.status == DemoWithdrawalStatus.processing
                          ? 'Record demo result'
                          : 'View request',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AdminDisbursement extends StatefulWidget {
  const AdminDisbursement({required this.onMessage, super.key});
  final ValueChanged<String> onMessage;

  @override
  State<AdminDisbursement> createState() => _AdminDisbursementState();
}

class _AdminDisbursementState extends State<AdminDisbursement> {
  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  Future<void> _copyProcessingCsv() async {
    final processing = demoOms.withdrawals.where(
      (request) => request.status == DemoWithdrawalStatus.processing,
    );
    final rows = <String>['reference,amount,method,account,reseller'];
    for (final request in processing) {
      rows.add(
        [
          request.id,
          request.amount.toString(),
          request.method,
          request.account,
          request.reseller.name,
        ].map(_escapeCsv).join(','),
      );
    }
    try {
      await Clipboard.setData(ClipboardData(text: rows.join('\n')));
      if (!mounted) return;
      widget.onMessage(
        'Processing-request CSV copied to clipboard. No payments were sent.',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        widget.onMessage(
          'Could not copy the CSV: ${error.message ?? error.code}',
        );
      }
    }
  }

  Future<void> _pasteResults() async {
    final input = TextEditingController();
    try {
      final content = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload disbursement result'),
          content: SizedBox(
            width: 460,
            child: TextField(
              controller: input,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'reference,status\\nWD-5001,approved',
                helperText: 'Paste result CSV rows: withdrawal reference, approved or cancelled',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, input.text),
              child: const Text('Validate & record demo result'),
            ),
          ],
        ),
      );
      if (!mounted || content == null) return;
      final parsed = <(DemoWithdrawal, bool)>[];
      final seen = <String>{};
      final issues = <String>[];
      for (final line in content.split(RegExp(r'\r?\n'))) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.toLowerCase().startsWith('reference,')) {
          continue;
        }
        final columns = trimmed
            .split(',')
            .map((value) => value.trim())
            .toList();
        if (columns.length != 2 || !seen.add(columns[0])) {
          issues.add('Malformed or duplicate row: $trimmed');
          continue;
        }
        DemoWithdrawal? request;
        for (final candidate in demoOms.withdrawals) {
          if (candidate.id == columns[0]) {
            request = candidate;
            break;
          }
        }
        if (request == null ||
            request.status != DemoWithdrawalStatus.processing) {
          issues.add('Unknown or non-processing request: ${columns[0]}');
          continue;
        }
        final status = columns[1].toLowerCase();
        if (status != 'approved' && status != 'cancelled') {
          issues.add('Unsupported result for ${columns[0]}: ${columns[1]}');
          continue;
        }
        parsed.add((request, status == 'approved'));
      }
      if (issues.isNotEmpty || parsed.isEmpty) {
        widget.onMessage(
          issues.isEmpty
              ? 'No valid result rows were provided.'
              : issues.take(2).join(' • '),
        );
        return;
      }
      for (final result in parsed) {
        demoOms.applyDemoDisbursementResult(result.$1, approved: result.$2);
      }
      setState(() {});
      widget.onMessage(
        'Recorded ${parsed.length} demo result(s) only. Provider transactions were not verified.',
      );
    } finally {
      input.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final processing = demoOms.withdrawals
        .where((request) => request.status == DemoWithdrawalStatus.processing)
        .length;
    final approved = demoOms.withdrawals
        .where((request) => request.status == DemoWithdrawalStatus.approved)
        .length;
    final cancelled = demoOms.withdrawals
        .where((request) => request.status == DemoWithdrawalStatus.cancelled)
        .length;
    return PageBody(
      children: [
        const SectionTitle('Disbursement', icon: Icons.account_balance_rounded),
        const Panel(
          child: Text(
            'DEMO ONLY • This workspace does not connect to a payment provider. CSV export and pasted results are local test data, not proof of a real transfer.',
            style: TextStyle(color: orange, height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            children: [
              _AdminActionRow(
                icon: Icons.download_rounded,
                title: 'Copy processing CSV',
                detail: 'Copy processing requests as CSV data',
                onTap: _copyProcessingCsv,
              ),
              const Divider(height: 1, color: line),
              _AdminActionRow(
                icon: Icons.account_balance_rounded,
                title: 'External Disbursement',
                detail: 'Requires a verified payment-provider integration',
                onTap: () => widget.onMessage(
                  'No payment provider is connected; disbursement cannot be made from this demo.',
                ),
              ),
              const Divider(height: 1, color: line),
              _AdminActionRow(
                icon: Icons.upload_file_rounded,
                title: 'Paste result CSV',
                detail: 'Validate and record demo-only results',
                onTap: _pasteResults,
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const SectionTitle('Disbursement Result'),
        Panel(
          child: Column(
            children: [
              KeyValueRow('Processing', '$processing', valueColor: blue),
              const Divider(height: 1, color: line),
              KeyValueRow('Approved', '$approved', valueColor: green),
              const Divider(height: 1, color: line),
              KeyValueRow('Cancelled', '$cancelled', valueColor: red),
              const Divider(height: 1, color: line),
              const KeyValueRow(
                'Duplicate protected',
                'Yes',
                valueColor: green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminActionRow extends StatelessWidget {
  const _AdminActionRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: brand),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(detail),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class AdminWallet extends StatelessWidget {
  const AdminWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final withdrawn = demoOms.withdrawals
        .where((request) => request.status == DemoWithdrawalStatus.approved)
        .fold(0, (total, request) => total + request.amount);
    return PageBody(
      children: [
        MetricCard(
          label: 'Capital Credited',
          value: '৳${demoOms.resellerCapital}',
          color: blue,
          icon: Icons.south_rounded,
        ),
        SizedBox(height: 12),
        MetricCard(
          label: 'Profit Credited',
          value: '৳${demoOms.resellerProfit}',
          color: green,
          icon: Icons.trending_up_rounded,
        ),
        SizedBox(height: 12),
        MetricCard(
          label: 'Approved Withdrawals',
          value: '৳$withdrawn',
          color: red,
          icon: Icons.north_rounded,
        ),
        SizedBox(height: 12),
        MetricCard(
          label: 'Current Balance',
          value: '৳${demoOms.totalWalletBalance}',
          color: brand,
          icon: Icons.account_balance_wallet_rounded,
        ),
        SizedBox(height: 20),
        SectionTitle('Transaction History', icon: Icons.history_rounded),
        if (demoOms.walletEntries.isEmpty && demoOms.withdrawals.isEmpty)
          const Panel(child: Text('No demo wallet transactions yet.'))
        else
          Panel(
            child: Column(
              children: [
                for (final entry in demoOms.walletEntries.reversed) ...[
                  KeyValueRow(
                    '${entry.reference} • ${entry.orderId} • ${entry.reseller.name}',
                    '+৳${entry.capital + entry.profit} (৳${entry.capital} + ৳${entry.profit})',
                    valueColor: green,
                  ),
                  const Divider(height: 1, color: line),
                ],
                for (final request in demoOms.withdrawals.where(
                  (request) => request.status == DemoWithdrawalStatus.approved,
                ))
                  KeyValueRow(
                    '${request.id} • ${request.reseller.name} • Demo',
                    '-৳${request.amount}',
                    valueColor: red,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  late final TextEditingController target = TextEditingController(
    text: '${demoOms.settings.initialBatchTarget}',
  );
  late final TextEditingController cycle = TextEditingController(
    text: '${demoOms.settings.cycleHours}',
  );
  late final TextEditingController transfer = TextEditingController(
    text: '${demoOms.settings.transferHours}',
  );
  late bool enabled = demoOms.settings.systemEnabled;
  late String profit = '${demoOms.settings.profitRate}%';
  late String growth = '${demoOms.settings.growthRate}%';

  @override
  void dispose() {
    target.dispose();
    cycle.dispose();
    transfer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextTarget =
        (demoOms.currentBatchTarget *
                (100 + int.parse(growth.replaceAll('%', ''))) /
                100)
            .round();
    return PageBody(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                'System Settings',
                icon: Icons.settings_rounded,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('System Status'),
                subtitle: Text(enabled ? 'System is ON' : 'System is OFF'),
                value: enabled,
                activeThumbColor: brand,
                onChanged: (value) => setState(() => enabled = value),
              ),
              DropdownButtonFormField<String>(
                initialValue: profit,
                decoration: const InputDecoration(labelText: 'Profit Rate'),
                items: const [
                  DropdownMenuItem(value: '20%', child: Text('20%')),
                  DropdownMenuItem(value: '30%', child: Text('30%')),
                  DropdownMenuItem(value: '40%', child: Text('40%')),
                ],
                onChanged: (value) => setState(() => profit = value ?? '30%'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Batch Target Amount',
                  hintText: '500',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: growth,
                decoration: const InputDecoration(
                  labelText: 'Batch Growth Rate',
                ),
                items: const [
                  DropdownMenuItem(value: '30%', child: Text('30%')),
                  DropdownMenuItem(value: '40%', child: Text('40%')),
                  DropdownMenuItem(value: '50%', child: Text('50%')),
                ],
                onChanged: (value) => setState(() => growth = value ?? '50%'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cycle,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Batch Cycle Period (Hours)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: transfer,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Transfer Period (Hours)',
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save Settings',
                icon: Icons.save_rounded,
                onPressed: () {
                  final targetAmount = int.tryParse(target.text.trim());
                  final cycleHours = int.tryParse(cycle.text.trim());
                  final transferHours = int.tryParse(transfer.text.trim());
                  if (targetAmount == null ||
                      targetAmount <= 0 ||
                      cycleHours == null ||
                      cycleHours <= 0 ||
                      transferHours == null ||
                      transferHours <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter positive whole-number amounts and hours.',
                        ),
                      ),
                    );
                    return;
                  }
                  try {
                    if (demoOms.currentBatchId == 'B-001' &&
                        demoOms.batchPaidTotal == 0 &&
                        targetAmount != demoOms.currentBatchTarget) {
                      demoOms.reconfigureInitialBatch(targetAmount);
                    } else {
                      demoOms.settings.initialBatchTarget = targetAmount;
                    }
                    demoOms.updateProfitRate(
                      int.parse(profit.replaceAll('%', '')),
                    );
                  } on StateError catch (error) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error.message)));
                    return;
                  }
                  demoOms.settings
                    ..systemEnabled = enabled
                    ..growthRate = int.parse(growth.replaceAll('%', ''))
                    ..cycleHours = cycleHours
                    ..transferHours = transferHours;
                  demoOms.auditLog.insert(
                    0,
                    'Demo settings saved: system ${enabled ? 'on' : 'off'}, profit ${demoOms.settings.profitRate}%, growth ${demoOms.settings.growthRate}%.',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Demo settings saved. Existing batch target is unchanged; product retail prices use the updated profit rate.',
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Current Batch Rules'),
        Panel(
          child: Column(
            children: [
              KeyValueRow('Growth Options', '30 / 40 / 50%'),
              const Divider(height: 1, color: line),
              const KeyValueRow('Division Unit', '৳50'),
              const Divider(height: 1, color: line),
              KeyValueRow('Cycle', '${cycle.text} Hours'),
              const Divider(height: 1, color: line),
              KeyValueRow('Transfer', '${transfer.text} Hours'),
              const Divider(height: 1, color: line),
              KeyValueRow(
                'Next target estimate',
                '৳$nextTarget',
                valueColor: brand,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Partial settlement is disabled. When the active batch target is fully paid, the previous batch is settled, processing orders are delivered, reseller capital and profit are credited, and the next batch is created using the configured growth formula.',
          style: TextStyle(color: muted, height: 1.55),
        ),
      ],
    );
  }
}
