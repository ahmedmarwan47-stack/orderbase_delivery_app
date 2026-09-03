part of '../imports/profile_imports.dart';

/// Who is signed in: photo, name, and the account they are signed in under.
///
/// The avatar is initials for now — there is no photo field on a courier yet,
/// and a grey silhouette says less about a person than their own initials do.
/// Swap the [CircleAvatar] fill for the image the moment the backend has one.
class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child:
          Row(
            children: [
              Container(
                width: AppSize.sW64,
                height: AppSize.sH64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceMuted,
                ),
                child: Text(
                  Courier.initials,
                  style: const TextStyle().setMainTextColor.s18.bold,
                ),
              ),
              16.szW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Courier.name,
                      style: const TextStyle().setMainTextColor.s18.bold,
                    ),
                    4.szH,
                    Text(
                      Courier.username,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setSecondaryColor.s12.regular,
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.profileMerchantNo.tr(
                        namedArgs: {'num': Courier.merchant},
                      ),
                      style: const TextStyle().setHintColor.s12.regular,
                    ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(
            horizontal: AppPadding.pW20,
            vertical: AppPadding.pH20,
          ),
    );
  }
}
