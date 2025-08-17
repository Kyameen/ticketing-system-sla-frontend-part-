// lib/utils/role_policy.dart
class RolePolicy {
  final String type;
  final String sub;

  RolePolicy({required String type, required String sub})
    : type = type.trim().toLowerCase(),
      sub = sub.trim().toLowerCase();

  bool get isCompany => type == 'company' || type == 'system_admin';

  bool get isCompanyAdmin =>
      isCompany &&
      (sub == 'admin' ||
          sub == 'company_admin' ||
          sub == 'company admin' ||
          sub.contains('admin')); // be forgiving with backend strings

  bool get isCompanyManager =>
      isCompany &&
      (sub == 'manager' ||
          sub == 'company_manager' ||
          sub == 'company manager' ||
          sub.contains('manager'));

  bool get isCompanyUser =>
      isCompany &&
      (sub == 'user' ||
          sub == 'employee' ||
          sub == 'staff' ||
          sub == 'agent' ||
          sub == 'company_user' ||
          sub == 'company user');

  bool get isClient =>
      type == 'client' || type == 'customer' || type == 'client_company';

  bool get isClientManager =>
      isClient &&
      (sub == 'manager' || sub == 'admin' || sub.contains('manager'));

  bool get isClientUser => isClient && !isClientManager;
}
