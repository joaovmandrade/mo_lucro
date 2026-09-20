import { Ionicons } from '@expo/vector-icons';
import { Tabs } from 'expo-router';
import type { ComponentProps } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { colors, radius, shadows } from '@/theme';

type IconName = keyof typeof Ionicons.glyphMap;

/** O expo-router não reexporta esse tipo, então derivamos dele mesmo. */
type BottomTabBarProps = Parameters<NonNullable<ComponentProps<typeof Tabs>['tabBar']>>[0];

type NavDef = {
  name: string;
  icon: IconName;
  activeIcon: IconName;
  label: string;
};

/** Mesma ordem e mesmos rótulos de _navItems em main.dart. */
export const navItems: NavDef[] = [
  { name: 'index', icon: 'home-outline', activeIcon: 'home', label: 'Dashboard' },
  { name: 'portfolio', icon: 'pie-chart-outline', activeIcon: 'pie-chart', label: 'Portfólio' },
  { name: 'transactions', icon: 'receipt-outline', activeIcon: 'receipt', label: 'Transações' },
  { name: 'goals', icon: 'flag-outline', activeIcon: 'flag', label: 'Metas' },
];

/** Porte de _BottomNav em main.dart — barra flutuante com pílula no item ativo. */
export function BottomNav({ state, navigation }: BottomTabBarProps) {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.safeArea, { paddingBottom: insets.bottom }]}>
      <View style={styles.bar}>
        {state.routes.map((route, index) => {
          const item = navItems.find((nav) => nav.name === route.name);
          if (!item) return null;

          const active = state.index === index;
          const color = active ? colors.primary : colors.textMuted;

          const onPress = () => {
            const event = navigation.emit({
              type: 'tabPress',
              target: route.key,
              canPreventDefault: true,
            });
            if (!active && !event.defaultPrevented) {
              navigation.navigate(route.name);
            }
          };

          return (
            <Pressable
              key={route.key}
              onPress={onPress}
              accessibilityRole="tab"
              accessibilityState={{ selected: active }}
              accessibilityLabel={item.label}
              style={[styles.item, active && styles.itemActive]}
            >
              <Ionicons name={active ? item.activeIcon : item.icon} size={22} color={color} />
              <Text numberOfLines={1} style={[styles.label, { color }, active && styles.labelActive]}>
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    backgroundColor: colors.bg0,
  },
  bar: {
    flexDirection: 'row',
    height: 66,
    marginHorizontal: 16,
    marginTop: 8,
    marginBottom: 12,
    padding: 6,
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  item: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  itemActive: {
    backgroundColor: 'rgba(37, 99, 235, 0.12)',
    borderColor: 'rgba(37, 99, 235, 0.20)',
  },
  label: {
    marginTop: 3,
    fontSize: 10,
    fontWeight: '500',
  },
  labelActive: {
    fontWeight: '700',
  },
});
