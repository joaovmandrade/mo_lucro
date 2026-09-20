import { MaterialIcons } from '@expo/vector-icons';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useState } from 'react';
import { Platform, Pressable, StyleSheet, Text, View } from 'react-native';

import { colors, radius } from '@/theme';
import { dateFull } from '@/utils/formatters';

/**
 * Campo de data com o mesmo visual do GestureDetector + showDatePicker usado
 * em add_transaction_page.dart e add_operation_page.dart.
 */
export function DateField({
  value,
  onChange,
  maximumDate = new Date(),
  minimumDate = new Date(2000, 0, 1),
}: {
  value: Date;
  onChange: (date: Date) => void;
  maximumDate?: Date;
  minimumDate?: Date;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Pressable style={styles.field} onPress={() => setOpen(true)}>
        <MaterialIcons name="calendar-today" size={18} color={colors.textMuted} />
        <Text style={styles.text}>{dateFull(value)}</Text>
        <MaterialIcons name="chevron-right" size={18} color={colors.textMuted} />
      </Pressable>

      {open ? (
        <DateTimePicker
          value={value}
          mode="date"
          display={Platform.OS === 'ios' ? 'spinner' : 'default'}
          maximumDate={maximumDate}
          minimumDate={minimumDate}
          onChange={(event, date) => {
            // No Android o picker é um diálogo: fecha sozinho ao escolher.
            if (Platform.OS === 'android') setOpen(false);
            if (event.type === 'set' && date) onChange(date);
            if (Platform.OS === 'ios' && event.type === 'dismissed') setOpen(false);
          }}
        />
      ) : null}

      {open && Platform.OS === 'ios' ? (
        <View style={styles.iosActions}>
          <Pressable onPress={() => setOpen(false)}>
            <Text style={styles.iosDone}>Concluir</Text>
          </Pressable>
        </View>
      ) : null}
    </>
  );
}

const styles = StyleSheet.create({
  field: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 16,
    backgroundColor: colors.bg4,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  text: { flex: 1, color: colors.textPrimary, fontSize: 14 },
  iosActions: { alignItems: 'flex-end', paddingVertical: 8 },
  iosDone: { color: colors.primary, fontSize: 14, fontWeight: '600' },
});
