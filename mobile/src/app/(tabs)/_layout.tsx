import { Tabs } from 'expo-router';

import { BottomNav, navItems } from '@/components/BottomNav';
import { colors } from '@/theme';

/** Porte de _AppShell em main.dart. */
export default function TabsLayout() {
  return (
    <Tabs
      tabBar={(props) => <BottomNav {...props} />}
      screenOptions={{
        headerShown: false,
        sceneStyle: { backgroundColor: colors.bg0 },
      }}
    >
      {navItems.map((item) => (
        <Tabs.Screen key={item.name} name={item.name} options={{ title: item.label }} />
      ))}
    </Tabs>
  );
}
