import type { useRouter } from 'expo-router';

type Router = ReturnType<typeof useRouter>;

/**
 * Volta para a tela anterior ou, quando não há histórico (a tela foi aberta
 * direto por um link), vai para o Dashboard. Sem isso, router.back() gera o
 * erro "The action 'GO_BACK' was not handled".
 */
export function goBack(router: Router, fallback: '/' | '/portfolio' | '/transactions' | '/goals' = '/') {
  if (router.canGoBack()) router.back();
  else router.replace(fallback);
}
