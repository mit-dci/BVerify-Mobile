package org.bverify.bverify;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

public class BVerifyPagerAdapter extends FragmentPagerAdapter {
    int tabCount;

    public BVerifyPagerAdapter(FragmentManager fm, int numberOfTabs) {
        super(fm);
        this.tabCount = numberOfTabs;
    }

    @Override
    public Fragment getItem(int position) {

        switch (position) {
            case 0:
                MyProofsFragment tab1 = new MyProofsFragment();
                return tab1;
            case 1:
                VerifyFragment tab2 = new VerifyFragment();
                return tab2;
            default:
                return null;
        }
    }

    @Override
    public int getCount() {
        return tabCount;
    }
}
