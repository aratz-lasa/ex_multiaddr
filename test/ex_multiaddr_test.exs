defmodule ExMultiaddrTest do
  use ExUnit.Case
  doctest Multiaddr

  @incorrect_addrs [
    "/ip4",
    "/ip4/::1",
    "/ip4/fdpsofodsajfdoisa",
    "/ip6",
    "/ip6zone",
    "/ip6zone/",
    "/ip6zone//ip6/fe80::1",
    "/udp",
    "/tcp",
    "/sctp",
    "/udp/65536",
    "/tcp/65536",
    "/quic/65536",
    "/onion/9imaq4ygg2iegci7:80",
    "/onion/aaimaq4ygg2iegci7:80",
    "/onion/timaq4ygg2iegci7:0",
    "/onion/timaq4ygg2iegci7:-1",
    "/onion/timaq4ygg2iegci7",
    "/onion/timaq4ygg2iegci@:666",
    "/onion3/9ww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd:80",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd7:80",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd:0",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd:-1",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyy@:666",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA7:80",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:0",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:0",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:-1",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA@:666",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA7:80",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:0",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:0",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA:-1",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA@:666",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzu",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzu77",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzu:80",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuq:-1",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzu@",
    "/udp/1234/sctp",
    "/udp/1234/udt/1234",
    "/udp/1234/utp/1234",
    "/ip4/127.0.0.1/udp/jfodsajfidosajfoidsa",
    "/ip4/127.0.0.1/udp",
    "/ip4/127.0.0.1/tcp/jfodsajfidosajfoidsa",
    "/ip4/127.0.0.1/tcp",
    "/ip4/127.0.0.1/quic/1234",
    "/ip4/127.0.0.1/ipfs",
    "/ip4/127.0.0.1/ipfs/tcp",
    "/ip4/127.0.0.1/p2p",
    "/ip4/127.0.0.1/p2p/tcp",
    "/unix",
    "/ip4/1.2.3.4/tcp/80/unix",
    "/ip4/127.0.0.1/tcp/9090/http/p2p-webcrt-direct",
    "/",
    ""
  ]

  @correct_addrs [
    "/ip4/1.2.3.4",
    "/ip4/0.0.0.0",
    "/ip6/::1",
    "/ip6/2601:9:4f81:9700:803e:ca65:66e8:c21",
    "/ip6/2601:9:4f81:9700:803e:ca65:66e8:c21/udp/1234/quic",
    "/ip6zone/x/ip6/fe80::1",
    "/ip6zone/x%y/ip6/fe80::1",
    "/ip6zone/x%y/ip6/::",
    "/ip6zone/x/ip6/fe80::1/udp/1234/quic",
    "/onion/timaq4ygg2iegci7:1234",
    "/onion/timaq4ygg2iegci7:80/http",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd:1234",
    "/onion3/vww6ybal4bd7szmgncyruucpgfkqahzddi37ktceo3ah7ngmcopnpyyd:80/http",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA/http",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA/udp/8080",
    "/garlic64/jT~IyXaoauTni6N4517EG8mrFUKpy0IlgZh-EY9csMAk82Odatmzr~YTZy8Hv7u~wvkg75EFNOyqb~nAPg-khyp2TS~ObUz8WlqYAM2VlEzJ7wJB91P-cUlKF18zSzVoJFmsrcQHZCirSbWoOknS6iNmsGRh5KVZsBEfp1Dg3gwTipTRIx7Vl5Vy~1OSKQVjYiGZS9q8RL0MF~7xFiKxZDLbPxk0AK9TzGGqm~wMTI2HS0Gm4Ycy8LYPVmLvGonIBYndg2bJC7WLuF6tVjVquiokSVDKFwq70BCUU5AU-EvdOD5KEOAM7mPfw-gJUG4tm1TtvcobrObqoRnmhXPTBTN5H7qDD12AvlwFGnfAlBXjuP4xOUAISL5SRLiulrsMSiT4GcugSI80mF6sdB0zWRgL1yyvoVWeTBn1TqjO27alr95DGTluuSqrNAxgpQzCKEWAyzrQkBfo2avGAmmz2NaHaAvYbOg0QSJz1PLjv2jdPW~ofiQmrGWM1cd~1cCqAAAA/tcp/8080",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuq",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuqzwas",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuqzwassw",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuq/http",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuq/tcp/8080",
    "/garlic32/566niximlxdzpanmn4qouucvua3k7neniwss47li5r6ugoertzuq/udp/8080",
    "/udp/0",
    "/tcp/0",
    "/sctp/0",
    "/udp/1234",
    "/tcp/1234",
    "/sctp/1234",
    "/udp/65535",
    "/tcp/65535",
    "/ipfs/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC",
    "/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC",
    "/udp/1234/sctp/1234",
    "/udp/1234/udt",
    "/udp/1234/utp",
    "/tcp/1234/http",
    "/tcp/1234/https",
    "/ipfs/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234",
    "/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234",
    "/ip4/127.0.0.1/udp/1234",
    "/ip4/127.0.0.1/udp/0",
    "/ip4/127.0.0.1/tcp/1234",
    "/ip4/127.0.0.1/tcp/1234/",
    "/ip4/127.0.0.1/udp/1234/quic",
    "/ip4/127.0.0.1/ipfs/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC",
    "/ip4/127.0.0.1/ipfs/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234",
    "/ip4/127.0.0.1/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC",
    "/ip4/127.0.0.1/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234",
    "/unix/a/b/c/d/e",
    "/unix/stdio",
    "/ip4/1.2.3.4/tcp/80/unix/a/b/c/d/e/f",
    "/ip4/127.0.0.1/ipfs/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234/unix/stdio",
    "/ip4/127.0.0.1/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSupNKC/tcp/1234/unix/stdio",
    "/ip4/127.0.0.1/tcp/9090/http/p2p-webrtc-direct"
  ]

  test "Incorrect addresses" do
    assert @incorrect_addrs
           |> Enum.map(fn a -> check_is_incorrect(a) end)
           |> Enum.all?()
  end

  def check_is_incorrect(address) do
    case Multiaddr.new_multiaddr_from_string(address) do
      {:error, _} ->
        true

      {:ok, _maddr} ->
        IO.puts("Address should have failed #{address}")
        false
    end
  end

  test "Correct addresses" do
    assert @correct_addrs
           |> Enum.map(fn a -> check_is_correct(a) end)
           |> Enum.all?()
  end

  def check_is_correct(address) do
    case Multiaddr.new_multiaddr_from_string(address) do
      {:error, _} ->
        IO.puts("Address shouldn't have failed #{address}")
        false

      {:ok, _maddr} ->
        true
    end
  end

  test "Create Multiaddr" do
    maddr_string = "/ip4/127.0.0.1/tcp/80"
    {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string(maddr_string)
    {:ok, maddr_2} = Multiaddr.new_multiaddr_from_bytes(maddr_1.bytes)
    assert Multiaddr.equal(maddr_1, maddr_2)
  end

  test "Create Multiaddr (variable length protocol)" do
    maddr_string = "/ip6zone/zone_ip6_23/tcp/80"
    {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string(maddr_string)
    {:ok, maddr_2} = Multiaddr.new_multiaddr_from_bytes(maddr_1.bytes)
    assert Multiaddr.equal(maddr_1, maddr_2)
  end

  test "Create Multiaddr (size 0)" do
    maddr_string = "/udt/tcp/80"
    {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string(maddr_string)
    {:ok, maddr_2} = Multiaddr.new_multiaddr_from_bytes(maddr_1.bytes)
    assert Multiaddr.equal(maddr_1, maddr_2)
  end

  test "Create Multiaddr (path)" do
    maddr_string = "/ip4/127.0.0.1/unix/home/multiaddr"
    {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string(maddr_string)
    {:ok, maddr_2} = Multiaddr.new_multiaddr_from_bytes(maddr_1.bytes)
    assert Multiaddr.equal(maddr_1, maddr_2)
  end

  test "Get Multiaddr Protocols" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    protocols = Multiaddr.protocols(maddr)
    assert length(protocols) == 2
    {:ok, prot_1} = Enum.fetch(protocols, 0)
    {:ok, prot_2} = Enum.fetch(protocols, 1)
    assert prot_1 == Multiaddr.Protocol.proto_ip4()
    assert prot_2 == Multiaddr.Protocol.proto_tcp()
  end

  test "Get Multiaddr Protocols (variable length protocol)" do
    maddr = create_multiaddr("/ip6zone/ip6zone_23/tcp/80")

    protocols = Multiaddr.protocols(maddr)
    assert length(protocols) == 2
    {:ok, prot_1} = Enum.fetch(protocols, 0)
    {:ok, prot_2} = Enum.fetch(protocols, 1)
    assert prot_1 == Multiaddr.Protocol.proto_ip6zone()
    assert prot_2 == Multiaddr.Protocol.proto_tcp()
  end

  test "Get Multiaddr Protocols (size 0)" do
    maddr = create_multiaddr("/udt/tcp/80")

    protocols = Multiaddr.protocols(maddr)
    assert length(protocols) == 2
    {:ok, prot_1} = Enum.fetch(protocols, 0)
    {:ok, prot_2} = Enum.fetch(protocols, 1)
    assert prot_1 == Multiaddr.Protocol.proto_udt()
    assert prot_2 == Multiaddr.Protocol.proto_tcp()
  end

  test "Get Multiaddr Protocols (path)" do
    maddr = create_multiaddr("/ip4/127.0.0.1/unix/home/multiaddr")

    protocols = Multiaddr.protocols(maddr)
    assert length(protocols) == 2
    {:ok, prot_1} = Enum.fetch(protocols, 0)
    {:ok, prot_2} = Enum.fetch(protocols, 1)
    assert prot_1 == Multiaddr.Protocol.proto_ip4()
    assert prot_2 == Multiaddr.Protocol.proto_unix()
  end

  test "Get protocol value" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    {:ok, ip4_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_ip4().code)
    {:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_tcp().code)
    assert ip4_value == "127.0.0.1"
    assert tcp_value == "80"
  end

  test "Get protocol value (variable length protocol)" do
    maddr = create_multiaddr("/ip6zone/ip6zone_23/tcp/80")

    {:ok, ip6zone_value} =
      Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_ip6zone().code)

    {:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_tcp().code)
    assert ip6zone_value == "ip6zone_23"
    assert tcp_value == "80"
  end

  test "Get protocol value (size 0)" do
    maddr = create_multiaddr("/udt/tcp/80")

    {:ok, udt_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_udt().code)

    {:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_tcp().code)
    assert udt_value == ""
    assert tcp_value == "80"
  end

  test "Get protocol value (path)" do
    maddr = create_multiaddr("/ip4/127.0.0.1/unix//home/multiaddr")

    {:ok, ip4_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_ip4().code)

    {:ok, unix_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_unix().code)
    assert ip4_value == "127.0.0.1"
    assert unix_value == "/home/multiaddr"
  end

  test "Multiadrr to string" do
    maddr = create_multiaddr("/ip4/127.0.0.1/tcp/80")

    string = Multiaddr.string(maddr)
    assert string == "/ip4/127.0.0.1/tcp/80"
  end

  test "Multiadrr to string (variable length protocol)" do
    maddr = create_multiaddr("/ip6zone/ip6zone_23/tcp/80")

    string = Multiaddr.string(maddr)
    assert string == "/ip6zone/ip6zone_23/tcp/80"
  end

  test "Multiadrr to string (size 0)" do
    maddr = create_multiaddr("/udt/tcp/80")

    string = Multiaddr.string(maddr)
    assert string == "/udt/tcp/80"
  end

  test "Encapsulate" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/ip4/127.0.0.1/tcp/80")
  end

  test "Encapsulate (variable length protocol)" do
    maddr_1 = create_multiaddr("/ip6zone/ip6zone_23")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/ip6zone/ip6zone_23/tcp/80")
  end

  test "Encapsulate (size 0)" do
    maddr_1 = create_multiaddr("/udt")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/udt/tcp/80")
  end

  test "Encapsulate (path)" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1")
    maddr_2 = create_multiaddr("/unix/home/multiaddr")

    {:ok, maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/ip4/127.0.0.1/unix/home/multiaddr")

    maddr_1 = create_multiaddr("/unix/home/multiaddr")
    maddr_2 = create_multiaddr("/ip4/127.0.0.1")

    {:error, _} = Multiaddr.encapsulate(maddr_1, maddr_2)
  end

  test "Decapsulate" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1/tcp/80")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.decapsulate(maddr_1, maddr_2)
    assert maddr.bytes == create_multiaddr("/ip4/127.0.0.1").bytes
  end

  test "Decapsulate (variable length protocol)" do
    maddr_1 = create_multiaddr("/ip6zone/ip6zone_23/tcp/80")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.decapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/ip6zone/ip6zone_23")
  end

  test "Decapsulate (size 0)" do
    maddr_1 = create_multiaddr("/udt/tcp/80")
    maddr_2 = create_multiaddr("/tcp/80")

    {:ok, maddr} = Multiaddr.decapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/udt")
  end

  test "Decapsulate (path)" do
    maddr_1 = create_multiaddr("/ip4/127.0.0.1/unix/home/multiaddr")
    maddr_2 = create_multiaddr("/unix/home/multiaddr")

    {:ok, maddr} = Multiaddr.decapsulate(maddr_1, maddr_2)
    assert maddr == create_multiaddr("/ip4/127.0.0.1")
  end

  defp create_multiaddr(maddr_string) when is_binary(maddr_string) do
    with {:ok, maddr} <- Multiaddr.new_multiaddr_from_string(maddr_string) do
      maddr
    end
  end
end
