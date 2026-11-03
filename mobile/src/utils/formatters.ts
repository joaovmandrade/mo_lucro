import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';

/**
 * Porte de lib/utils/formatters.dart.
 *
 * Observação sobre separadores: no app Flutter só as datas usavam locale pt_BR
 * (initializeDateFormatting). Os NumberFormat de percentual não recebiam locale,
 * então caíam no padrão en_US e imprimiam ponto decimal. O comportamento foi
 * mantido igual aqui para a migração não mudar o que a tela mostra hoje.
 */

const brl = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

export function currency(value: number): string {
  return brl.format(value);
}

export function currencyCompact(value: number): string {
  const abs = Math.abs(value);
  if (abs >= 1_000_000) return `R$ ${(value / 1_000_000).toFixed(1)}M`;
  if (abs >= 1_000) return `R$ ${(value / 1_000).toFixed(1)}K`;
  return brl.format(value);
}

/** Percentual no formato brasileiro (vírgula decimal), como os valores em reais. */
export function percentText(value: number, digits = 2): string {
  return `${value.toFixed(digits).replace('.', ',')}%`;
}

/** Sempre com sinal explícito, como +1,25% ou -0,40%. */
export function percent(value: number): string {
  const sign = value < 0 ? '-' : '+';
  return `${sign}${percentText(Math.abs(value))}`;
}

export function percentSimple(value: number): string {
  return percentText(value);
}

/** dd/MM/yy */
export function dateShort(date: Date): string {
  return format(date, 'dd/MM/yy', { locale: ptBR });
}

/** dd MMM yyyy */
export function dateFull(date: Date): string {
  return format(date, 'dd MMM yyyy', { locale: ptBR });
}

/** MMMM yyyy */
export function month(date: Date): string {
  return format(date, 'MMMM yyyy', { locale: ptBR });
}
