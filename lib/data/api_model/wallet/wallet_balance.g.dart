// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletBalanceImpl _$$WalletBalanceImplFromJson(Map<String, dynamic> json) =>
    _$WalletBalanceImpl(
      balance: json['balance'] as num? ?? 0,
      pendingBalance: json['pending_balance'] as num? ?? 0,
      heldBalance: json['held_balance'] as num? ?? 0,
      availableRaw: json['available'] as num?,
      lifetimeEarned: json['lifetime_earned'] as num? ?? 0,
      lifetimeSpent: json['lifetime_spent'] as num? ?? 0,
      isFrozen: json['is_frozen'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'UZS',
    );

Map<String, dynamic> _$$WalletBalanceImplToJson(_$WalletBalanceImpl instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'pending_balance': instance.pendingBalance,
      'held_balance': instance.heldBalance,
      'available': instance.availableRaw,
      'lifetime_earned': instance.lifetimeEarned,
      'lifetime_spent': instance.lifetimeSpent,
      'is_frozen': instance.isFrozen,
      'currency': instance.currency,
    };
