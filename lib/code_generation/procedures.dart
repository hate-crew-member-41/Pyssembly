const binToDecStrProc =
	'BinToDecStr proc addr_a: dword, num_bits_a: dword, addr_s: dword\n'
	'local index: dword, watcher: dword, num_groups_a: dword\n'

	'mov esi, addr_a\n'
	'mov edi, addr_s\n'

	'mov index, 0\n'

	'mov ecx, num_bits_a\n'
	'shr ecx, 5\n'
	'mov num_groups_a, ecx\n'

	'divide_by_10:\n'
	'xor ebx, ebx\n'
	'xor edx, edx\n'
	'mov ecx, num_groups_a\n'

		'partial_fraction:\n'
			'dec ecx\n'

			'mov eax, [esi + 4*ecx]\n'
			'mov watcher, ebx\n'
			'mov ebx, 10\n'
			'div ebx\n'

			'mov [esi + 4*ecx], eax\n'
			'mov ebx, watcher\n'
			'or ebx, eax\n'

			'cmp ecx, 0\n'
			'jne partial_fraction\n'

		'add dl, 48\n'
		'mov eax, index\n'
		'mov byte ptr [edi + eax], dl\n'
		'inc eax\n'
		'mov index, eax\n'

		'cmp ebx, 0\n'
		'jne divide_by_10\n'

	'mov byte ptr [edi + eax], 0\n'

	'cmp eax, 1\n'
	'je exit_\n'

	'mov ecx, eax\n'
	'dec eax\n'
	'shr ecx, 1\n'
	'swap:\n'
		'dec ecx\n'

		'mov bl, byte ptr [edi + ecx]\n'
		'mov edx, eax\n'
		'sub edx, ecx\n'
		'mov bh, byte ptr [edi + edx]\n'

		'mov byte ptr [edi + edx], bl\n'
		'mov byte ptr [edi + ecx], bh\n'

		'cmp ecx, 0\n'
		'jne swap\n'

	'exit_:\n'
	'ret 12\n'
	'BinToDecStr endp\n';
